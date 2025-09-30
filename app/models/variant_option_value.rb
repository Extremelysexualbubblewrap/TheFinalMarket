class VariantOptionValue < ApplicationRecord
  belongs_to :variant
  belongs_to :option_value

  validates :variant_id, uniqueness: { scope: :option_value_id }
  validate :option_value_belongs_to_product

  private

  def option_value_belongs_to_product
    return if option_value.option_type.product_id == variant.product_id
    
    errors.add(:option_value, "must belong to the same product as the variant")
  end
end