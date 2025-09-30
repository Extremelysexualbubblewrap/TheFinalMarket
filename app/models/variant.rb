class Variant < ApplicationRecord
  belongs_to :product
  has_many :variant_option_values, dependent: :destroy
  has_many :option_values, through: :variant_option_values
  has_one_attached :image

  validates :sku, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :generate_sku, on: :create

  def name
    option_values.map(&:name).join(' / ')
  end

  private

  def generate_sku
    return if sku.present?
    
    base = product.name.parameterize[0..5].upcase
    random = SecureRandom.alphanumeric(6).upcase
    self.sku = "#{base}-#{random}"
  end
end