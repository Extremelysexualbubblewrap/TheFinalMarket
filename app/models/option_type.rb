class OptionType < ApplicationRecord
  belongs_to :product
  has_many :option_values, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :product_id }

  # Example: Size, Color, Material
end