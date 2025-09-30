class CompareItem < ApplicationRecord
  belongs_to :compare_list
  belongs_to :product

  validates :product_id, uniqueness: { scope: :compare_list_id }
  validate :same_category_products

  private

  def same_category_products
    return if compare_list.compare_items.empty?

    existing_categories = compare_list.products.joins(:categories).pluck('categories.id').uniq
    product_categories = product.category_ids

    unless (existing_categories & product_categories).any?
      errors.add(:product, "must be in the same category as other compared products")
    end
  end
end