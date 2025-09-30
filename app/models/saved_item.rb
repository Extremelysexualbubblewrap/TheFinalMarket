class SavedItem < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :variant, optional: true

  validates :product_id, uniqueness: { scope: [:user_id, :variant_id] }
  validate :product_availability

  private

  def product_availability
    return unless product.present?
    
    if product.user_id == user_id
      errors.add(:product, "cannot save your own product")
    end
  end
end