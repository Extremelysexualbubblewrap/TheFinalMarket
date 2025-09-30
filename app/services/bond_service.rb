class BondService
  DEFAULT_BOND_AMOUNT = Money.new(50000) # $500

  def initialize(user)
    @user = user
  end

  # Create a new bond for a seller
  def create_bond(amount = DEFAULT_BOND_AMOUNT)
    return @user.bond if @user.bond&.pending?

    Bond.create!(
      user: @user,
      amount: amount
    )
  end

  # Process a successful bond payment
  def process_payment(bond, payment_transaction)
    bond.pay!(payment_transaction)
    
    # Notify seller
    NotificationService.notify(
      user: @user,
      title: "Seller Bond Activated",
      body: "Your seller bond of #{bond.amount.format} has been successfully paid and is now active."
    )
  end

  # Forfeit a seller's bond
  def forfeit_bond(bond, reason)
    bond.forfeit!(reason)

    # Notify seller
    NotificationService.notify(
      user: @user,
      title: "Seller Bond Forfeited",
      body: "Your seller bond has been forfeited. Reason: #{reason}",
      category: :account_warning
    )
  end

  # Return a seller's bond
  def return_bond(bond)
    # Use Square API to refund the original payment
    payment_transaction = bond.bond_transactions.find_by(transaction_type: :payment)&.payment_transaction
    return false unless payment_transaction

    payment_service = SquarePaymentService.new
    result = payment_service.refund_payment(
      payment_id: payment_transaction.square_payment_id,
      amount: bond.amount,
      reason: 'Seller bond returned'
    )

    if result.success?
      bond.return!
      # Notify seller
      NotificationService.notify(
        user: @user,
        title: "Seller Bond Returned",
        body: "Your seller bond of #{bond.amount.format} has been returned to your original payment method."
      )
      true
    else
      # Log error
      Rails.logger.error("Failed to return bond for user #{@user.id}: #{result.error}")
      false
    end
  end
end
