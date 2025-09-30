class AnalyticsService
  def initialize(start_date: 30.days.ago, end_date: Time.current)
    @start_date = start_date.beginning_of_day
    @end_date = end_date.end_of_day
  end

  def sales_overview
    {
      total_revenue: calculate_total_revenue,
      total_orders: calculate_total_orders,
      average_order_value: calculate_average_order_value,
      revenue_by_day: revenue_by_day,
      top_products: top_selling_products,
      top_categories: top_categories,
      conversion_rate: calculate_conversion_rate
    }
  end

  def user_metrics
    {
      total_users: calculate_total_users,
      new_users: calculate_new_users,
      active_users: calculate_active_users,
      user_growth: calculate_user_growth
    }
  end

  def product_performance
    {
      top_viewed: top_viewed_products,
      top_searched: top_searched_terms,
      top_wishlisted: top_wishlisted_products,
      inventory_status: inventory_status
    }
  end

  def customer_insights
    {
      customer_segments: analyze_customer_segments,
      lifetime_value: calculate_customer_ltv,
      retention_rate: calculate_retention_rate,
      churn_rate: calculate_churn_rate
    }
  end

  private

  def calculate_total_revenue
    Order.completed
         .where(created_at: @start_date..@end_date)
         .sum(:total_amount)
  end

  def calculate_total_orders
    Order.completed
         .where(created_at: @start_date..@end_date)
         .count
  end

  def calculate_average_order_value
    completed_orders = Order.completed.where(created_at: @start_date..@end_date)
    return 0 if completed_orders.empty?
    completed_orders.average(:total_amount).to_f
  end

  def revenue_by_day
    Order.completed
         .where(created_at: @start_date..@end_date)
         .group_by_day(:created_at)
         .sum(:total_amount)
  end

  def top_selling_products(limit = 10)
    LineItem.joins(:order, :product)
            .where(orders: { status: 'completed', created_at: @start_date..@end_date })
            .group('products.id', 'products.name')
            .select('products.name, SUM(line_items.quantity) as total_sold, SUM(line_items.price * line_items.quantity) as revenue')
            .order('total_sold DESC')
            .limit(limit)
  end

  def top_categories(limit = 5)
    Category.joins(products: { line_items: :order })
           .where(orders: { status: 'completed', created_at: @start_date..@end_date })
           .group('categories.id', 'categories.name')
           .select('categories.name, COUNT(DISTINCT orders.id) as total_orders, SUM(line_items.price * line_items.quantity) as revenue')
           .order('revenue DESC')
           .limit(limit)
  end

  def calculate_conversion_rate
    total_visits = Ahoy::Visit.where(started_at: @start_date..@end_date).count
    return 0 if total_visits.zero?
    
    (calculate_total_orders.to_f / total_visits * 100).round(2)
  end

  def top_viewed_products(limit = 10)
    Ahoy::Event.where(name: 'Product View', time: @start_date..@end_date)
               .group('properties ->> \'product_id\'')
               .select('properties ->> \'product_id\' as product_id, COUNT(*) as view_count')
               .order('view_count DESC')
               .limit(limit)
  end

  def top_searched_terms(limit = 10)
    Ahoy::Event.where(name: 'product_search', time: @start_date..@end_date)
               .group('properties ->> \'query\'')
               .select('properties ->> \'query\' as term, COUNT(*) as search_count')
               .order('search_count DESC')
               .limit(limit)
  end

  def analyze_customer_segments
    {
      new: new_customers_count,
      returning: returning_customers_count,
      loyal: loyal_customers_count,
      inactive: inactive_customers_count
    }
  end

  def calculate_customer_ltv
    completed_orders = Order.completed.where(created_at: @start_date..@end_date)
    customers_with_orders = completed_orders.select('user_id, SUM(total_amount) as total_spent')
                                          .group(:user_id)
                                          .having('COUNT(*) > 0')
    
    return 0 if customers_with_orders.empty?
    
    customers_with_orders.average('total_spent').to_f
  end

  def calculate_retention_rate
    total_customers = User.where('created_at < ?', @start_date).count
    retained_customers = User.joins(:orders)
                           .where(orders: { created_at: @start_date..@end_date })
                           .where('users.created_at < ?', @start_date)
                           .distinct
                           .count
    
    return 0 if total_customers.zero?
    (retained_customers.to_f / total_customers * 100).round(2)
  end

  private

  def new_customers_count
    User.where(created_at: @start_date..@end_date).count
  end

  def returning_customers_count
    User.joins(:orders)
        .where(orders: { created_at: @start_date..@end_date })
        .group('users.id')
        .having('COUNT(orders.id) > 1')
        .count
        .count
  end

  def loyal_customers_count
    User.joins(:orders)
        .where(orders: { created_at: @start_date..@end_date })
        .group('users.id')
        .having('COUNT(orders.id) >= 3')
        .count
        .count
  end

  def inactive_customers_count
    User.where('created_at < ?', 90.days.ago)
        .where.not(id: Order.where('created_at > ?', 90.days.ago).select(:user_id))
        .count
  end
end