class DisputeResolution < ApplicationRecord
  belongs_to :dispute
  
  enum resolution_type: {
    resolved: 0,    # Release funds to seller
    refunded: 1,    # Full refund to buyer
    partially_refunded: 2  # Partial refund to buyer
  }

  validates :resolution_type, presence: true
  validates :notes, presence: true, length: { minimum: 20, maximum: 1000 }
  validates :refund_amount, presence: true, if: :refund_required?
  validate :refund_amount_within_limits, if: :refund_required?

  private

  def refund_required?
    ['refunded', 'partially_refunded'].include?(resolution_type)
  end

  def refund_amount_within_limits
    return unless refund_amount.present?
    
    if resolution_type == 'refunded' && refund_amount != dispute.amount
      errors.add(:refund_amount, "must equal the full dispute amount for full refunds")
    elsif resolution_type == 'partially_refunded'
      if refund_amount >= dispute.amount
        errors.add(:refund_amount, "must be less than the full amount for partial refunds")
      elsif refund_amount <= 0
        errors.add(:refund_amount, "must be greater than 0")
      end
    end
  end
end