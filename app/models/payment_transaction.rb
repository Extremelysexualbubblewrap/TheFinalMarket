class PaymentTransaction < ApplicationRecord
  belongs_to :source_account, class_name: 'PaymentAccount'
  belongs_to :target_account, class_name: 'PaymentAccount', optional: true
  belongs_to :order, optional: true

  monetize :amount_cents

  enum transaction_type: {
    purchase: 'purchase',
    refund: 'refund',
    payout: 'payout',
    fee: 'fee',
    bond: 'bond',
    bond_refund: 'bond_refund'
  }

  enum status: {
    pending: 'pending',
    processing: 'processing',
    held: 'held',
    completed: 'completed',
    failed: 'failed',
    refunded: 'refunded',
    cancelled: 'cancelled'
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true
  validates :status, presence: true
  validates :square_payment_id, uniqueness: true, allow_nil: true
  validates :square_refund_id, uniqueness: true, allow_nil: true
  validates :square_transfer_id, uniqueness: true, allow_nil: true

  before_create :set_description
  after_create :process_transaction
  
  private

  def set_description
    self.description = case transaction_type
    when 'purchase'
      "Payment for Order ##{order.id}"
    when 'refund'
      "Refund for Order ##{order.id}"
    when 'payout'
      "Payout to connected account"
    when 'fee'
      "Platform fee"
    when 'bond'
      "Seller security bond"
    when 'bond_refund'
      "Seller bond refund"
    end
  end

  def process_transaction
    case transaction_type
    when 'purchase'
      ProcessPurchaseJob.perform_later(self)
    when 'refund'
      ProcessRefundJob.perform_later(self)
    when 'payout'
      ProcessPayoutJob.perform_later(self)
    end
  end
end
