class DashboardDecorator < SimpleDelegator
  def initialize(user)
    super(user)
  end

  def total_earnings
    Money.new(payment_transactions.where(transaction_type: :payout).sum(:amount_cents)).format
  end

  def pending_payouts
    Money.new(escrow_transactions.where(status: :held).sum(:amount_cents)).format
  end

  def recent_sales
    orders.where('created_at > ?', 30.days.ago).count
  end

  def bond_status_display
    bond_status.humanize
  end

  def bond_amount
    bond&.amount&.format || "N/A"
  end
end
