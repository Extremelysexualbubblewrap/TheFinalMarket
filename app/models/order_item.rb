class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :item

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_unit_price, on: :create

  def subtotal
    unit_price * quantity
  end

  private

  def set_unit_price
    self.unit_price = item.price if unit_price.nil?
  end
end
