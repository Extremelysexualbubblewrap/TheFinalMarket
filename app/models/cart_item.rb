class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validate :item_available_for_purchase
  validate :seller_cannot_buy_own_item

  def subtotal
    item.price * quantity
  end

  private

  def item_available_for_purchase
    unless item&.active?
      errors.add(:item, "is not available for purchase")
    end
  end

  def seller_cannot_buy_own_item
    if item&.user_id == user_id
      errors.add(:base, "You cannot add your own items to cart")
    end
  end
end
