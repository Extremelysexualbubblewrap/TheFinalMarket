class Bond < ApplicationRecord
  belongs_to :user
  has_many :bond_transactions

  monetize :amount_cents

  # Bond statuses
  enum status: {
    pending: 'pending',       # Waiting for payment
    active: 'active',         # Bond is paid and active
    forfeited: 'forfeited',   # Bond has been forfeited
    returned: 'returned',     # Bond has been returned to the seller
    disputed: 'disputed'      # Bond is under dispute
  }

  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  before_validation :set_default_status, on: :create

  def pay!(payment_transaction)
    return false unless pending?
    
    transaction do
      update!(status: :active, paid_at: Time.current)
      bond_transactions.create!(
        payment_transaction: payment_transaction,
        transaction_type: :payment,
        amount: amount
      )
    end
  end

  def forfeit!(reason)
    return false unless active?

    transaction do
      update!(status: :forfeited, forfeited_at: Time.current, forfeiture_reason: reason)
      bond_transactions.create!(
        transaction_type: :forfeiture,
        amount: amount,
        metadata: { reason: reason }
      )
    end
  end

  def return!
    return false unless active?

    transaction do
      update!(status: :returned, returned_at: Time.current)
      bond_transactions.create!(
        transaction_type: :refund,
        amount: amount
      )
    end
  end

  private

  def set_default_status
    self.status ||= :pending
  end
end
