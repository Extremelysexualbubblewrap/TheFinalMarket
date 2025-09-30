class EscrowService
  def initialize(order)
    @order = order
  end

  # Create a new escrow transaction for an order
  def create_escrow(payment_transaction)
    EscrowTransaction.create!(
      order: @order,
      payment_transaction: payment_transaction,
      buyer_account: @order.buyer.payment_account,
      seller_account: @order.seller.payment_account,
      amount: @order.total_amount,
      fee: calculate_fee(@order.total_amount),
      release_at: calculate_release_date
    )
  end

  # Check all transactions that are ready for automatic release
  def self.process_pending_releases
    EscrowTransaction.held.where('release_at <= ?', Time.current).find_each do |transaction|
      next if transaction.disputed?
      transaction.start_release!
    end
  end

  # Handle dispute creation
  def create_dispute(reason:, details:)
    escrow_transaction = @order.escrow_transaction
    return false unless escrow_transaction&.can_dispute?

    ActiveRecord::Base.transaction do
      dispute = @order.disputes.create!(
        buyer: @order.buyer,
        seller: @order.seller,
        escrow_transaction: escrow_transaction,
        amount: escrow_transaction.amount,
        dispute_type: :order_issue,
        details: details,
        reason: reason
      )

      escrow_transaction.mark_disputed!
      
      # Create initial dispute evidence
      dispute.dispute_evidences.create!(
        evidence_type: :buyer_statement,
        content: details,
        submitted_by: @order.buyer
      )

      # Notify seller
      NotificationService.notify(
        user: @order.seller,
        title: "New Dispute Filed",
        body: "A dispute has been filed for order ##{@order.id}",
        link: Rails.application.routes.url_helpers.dispute_path(dispute)
      )

      dispute
    end
  end

  private

  def calculate_fee(amount)
    calculator = FeeCalculator.new(@order)
    fees = calculator.calculate_total_fees
    fees[:total_fee]
  end

  def calculate_release_date
    # Funds are held for 3 days by default
    # This can be adjusted based on seller rating, transaction amount, etc.
    base_hold_period = 3.days

    release_at = Time.current + base_hold_period

    # Add additional hold time for high-value transactions
    if @order.total_amount >= Money.new(100000) # $1000
      release_at += 2.days
    end

    # Add additional hold time for new sellers
    unless @order.seller.experienced_seller?
      release_at += 2.days
    end

    release_at
  end
end