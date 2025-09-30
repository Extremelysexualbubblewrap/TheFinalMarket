class OptionValue < ApplicationRecord
  belongs_to :option_type
  has_many :variant_option_values, dependent: :destroy
  has_many :variants, through: :variant_option_values

  validates :name, presence: true
  validates :name, uniqueness: { scope: :option_type_id }

  # Example: Small, Red, Cotton
end