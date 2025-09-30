class CompareList < ApplicationRecord
  belongs_to :user
  has_many :compare_items, dependent: :destroy
  has_many :products, through: :compare_items

  validates :user_id, presence: true
  validate :products_limit

  MAX_PRODUCTS = 4

  private

  def products_limit
    if compare_items.size > MAX_PRODUCTS
      errors.add(:base, "Can't compare more than #{MAX_PRODUCTS} products at once")
    end
  end
end