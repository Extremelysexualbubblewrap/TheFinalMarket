class Wishlist < ApplicationRecord
  belongs_to :user
  has_many :wishlist_items, dependent: :destroy
  has_many :products, through: :wishlist_items

  validates :user_id, presence: true

  def add_product(product)
    wishlist_items.find_or_create_by!(product: product)
  end

  def remove_product(product)
    wishlist_items.find_by(product: product)&.destroy
  end

  def has_product?(product)
    products.include?(product)
  end
end