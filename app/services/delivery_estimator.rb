class DeliveryEstimator
  def initialize(cart)
    @cart = cart
  end

  def estimate_delivery
    # Base delivery time in days
    base_time = 3

    # Add processing time based on number of items
    processing_time = calculate_processing_time
    
    # Add handling time for special items
    handling_time = calculate_handling_time
    
    # Calculate total estimated days
    total_days = base_time + processing_time + handling_time
    
    # Return delivery window
    {
      earliest: Date.current + total_days,
      latest: Date.current + total_days + 2,
      expedited_available: expedited_available?,
      expedited_days: total_days - 2
    }
  end

  private

  def calculate_processing_time
    items_count = @cart.line_items.sum(:quantity)
    case items_count
    when 1..3 then 0
    when 4..10 then 1
    else 2
    end
  end

  def calculate_handling_time
    special_handling = @cart.line_items.any? do |item|
      item.product.tags.pluck(:name).any? { |tag| %w[fragile oversized custom].include?(tag) }
    end
    
    special_handling ? 1 : 0
  end

  def expedited_available?
    return false if @cart.line_items.empty?
    
    # Check if all items are eligible for expedited shipping
    @cart.line_items.all? do |item|
      !item.product.tags.pluck(:name).include?('oversized')
    end
  end
end