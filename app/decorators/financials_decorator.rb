class FinancialsDecorator
  def total_revenue
    Money.new(PaymentTransaction.where(status: 'succeeded').sum(:amount_cents)).format
  end

  def fees_collected
    Money.new(EscrowTransaction.where(status: 'released').sum(:fee_cents)).format
  end

  def total_volume
    Money.new(Order.where(status: 'completed').sum(:total_amount_cents)).format
  end

  def successful_transactions
    PaymentTransaction.where(status: 'succeeded').count
  end

  def pending_escrow
    Money.new(EscrowTransaction.where(status: 'held').sum(:amount_cents)).format
  end

  def active_bonds
    Money.new(Bond.where(status: 'active').sum(:amount_cents)).format
  end
end
