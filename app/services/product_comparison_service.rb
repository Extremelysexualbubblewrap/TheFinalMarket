class ProductComparisonService
  def initialize(products)
    @products = products
  end

  def compare_attributes
    return {} if @products.empty?

    {
      basic_info: basic_info,
      specifications: specifications,
      pricing: pricing,
      ratings: ratings,
      availability: availability,
      shipping: shipping_info
    }
  end

  private

  def basic_info
    @products.map do |product|
      {
        id: product.id,
        name: product.name,
        description: product.description,
        brand: product.user.username,
        categories: product.categories.pluck(:name),
        tags: product.tags.pluck(:name)
      }
    end
  end

  def specifications
    @products.map do |product|
      specs = {}
      
      # Get all option types (specifications)
      product.option_types.each do |option_type|
        specs[option_type.name] = option_type.option_values.pluck(:name).join(", ")
      end

      specs
    end
  end

  def pricing
    @products.map do |product|
      {
        base_price: product.price,
        variants: product.variants.map { |v| { name: v.name, price: v.price } },
        min_price: product.variants.minimum(:price) || product.price,
        max_price: product.variants.maximum(:price) || product.price
      }
    end
  end

  def ratings
    @products.map do |product|
      reviews = product.reviews
      {
        average_rating: reviews.average(:rating)&.round(1) || 0,
        review_count: reviews.count,
        rating_distribution: rating_distribution(reviews)
      }
    end
  end

  def rating_distribution(reviews)
    distribution = reviews.group(:rating).count
    (1..5).map { |rating| distribution[rating] || 0 }
  end

  def availability
    @products.map do |product|
      {
        in_stock: product.variants.sum(:stock_quantity) > 0,
        total_stock: product.variants.sum(:stock_quantity),
        variants_available: product.variants.count
      }
    end
  end

  def shipping_info
    @products.map do |product|
      {
        shipping_time: estimate_shipping_time(product),
        free_shipping: qualifies_for_free_shipping?(product),
        shipping_restrictions: get_shipping_restrictions(product)
      }
    end
  end

  def estimate_shipping_time(product)
    return "3-5 business days" unless product.tags.pluck(:name).include?('oversized')
    "5-7 business days"
  end

  def qualifies_for_free_shipping?(product)
    product.price >= 50 # Example threshold
  end

  def get_shipping_restrictions(product)
    restrictions = []
    restrictions << "Oversized item" if product.tags.pluck(:name).include?('oversized')
    restrictions << "Fragile item" if product.tags.pluck(:name).include?('fragile')
    restrictions
  end
end