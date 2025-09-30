class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  belongs_to :product
  counter_culture :wishlist

  validates :product_id, uniqueness: { scope: :wishlist_id }
  validate :product_availability

  private

  def product_availability
    return unless product.present?
    
    if product.user_id == wishlist.user_id
      errors.add(:product, "cannot add your own product to wishlist")
    end
  end
end