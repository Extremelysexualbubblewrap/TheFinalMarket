class CohortAnalysisService
  def initialize(start_date: 12.months.ago, end_date: Time.current)
    @start_date = start_date.beginning_of_month
    @end_date = end_date.end_of_month
  end

  def analyze
    {
      retention_matrix: calculate_retention_matrix,
      lifetime_value_matrix: calculate_ltv_matrix,
      cohort_trends: analyze_cohort_trends,
      engagement_metrics: calculate_engagement_metrics
    }
  end

  private

  def calculate_retention_matrix
    cohorts = {}
    
    (@start_date.to_date..@end_date.to_date).select { |d| d.day == 1 }.each do |cohort_date|
      # Get users who joined in this cohort month
      cohort_users = User.where(created_at: cohort_date.all_month)
      next if cohort_users.empty?

      retention_data = []
      
      # Calculate retention for each subsequent month
      (0..months_between(cohort_date, @end_date)).each do |month|
        activity_month = cohort_date + month.months
        
        active_users = cohort_users.joins(:orders)
                                 .where(orders: { created_at: activity_month.all_month })
                                 .distinct
                                 .count
        
        retention_rate = ((active_users.to_f / cohort_users.count) * 100).round(2)
        retention_data << retention_rate
      end

      cohorts[cohort_date.strftime('%Y-%m')] = retention_data
    end

    cohorts
  end

  def calculate_ltv_matrix
    cohorts = {}
    
    (@start_date.to_date..@end_date.to_date).select { |d| d.day == 1 }.each do |cohort_date|
      cohort_users = User.where(created_at: cohort_date.all_month)
      next if cohort_users.empty?

      ltv_data = []
      
      (0..months_between(cohort_date, @end_date)).each do |month|
        activity_month = cohort_date + month.months
        
        total_revenue = Order.completed
                           .where(user_id: cohort_users.select(:id))
                           .where(created_at: activity_month.all_month)
                           .sum(:total_amount)
        
        average_ltv = (total_revenue / cohort_users.count).round(2)
        ltv_data << average_ltv
      end

      cohorts[cohort_date.strftime('%Y-%m')] = ltv_data
    end

    cohorts
  end

  def analyze_cohort_trends
    cohorts = {}
    
    (@start_date.to_date..@end_date.to_date).select { |d| d.day == 1 }.each do |cohort_date|
      cohort_users = User.where(created_at: cohort_date.all_month)
      next if cohort_users.empty?

      cohorts[cohort_date.strftime('%Y-%m')] = {
        total_users: cohort_users.count,
        first_purchase_rate: calculate_first_purchase_rate(cohort_users),
        average_order_frequency: calculate_order_frequency(cohort_users),
        category_preferences: analyze_category_preferences(cohort_users)
      }
    end

    cohorts
  end

  def calculate_engagement_metrics
    cohorts = {}
    
    (@start_date.to_date..@end_date.to_date).select { |d| d.day == 1 }.each do |cohort_date|
      cohort_users = User.where(created_at: cohort_date.all_month)
      next if cohort_users.empty?

      metrics = {
        average_session_duration: calculate_average_session_duration(cohort_users),
        product_view_rate: calculate_product_view_rate(cohort_users),
        cart_addition_rate: calculate_cart_addition_rate(cohort_users),
        wishlist_usage: calculate_wishlist_usage(cohort_users)
      }

      cohorts[cohort_date.strftime('%Y-%m')] = metrics
    end

    cohorts
  end

  def months_between(start_date, end_date)
    ((end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)).abs
  end

  def calculate_first_purchase_rate(users)
    users_with_orders = users.joins(:orders)
                            .where('orders.created_at <= ?', users.select('created_at + interval \'30 days\''))
                            .distinct
                            .count

    ((users_with_orders.to_f / users.count) * 100).round(2)
  end

  def calculate_order_frequency(users)
    total_orders = Order.completed
                       .where(user_id: users.select(:id))
                       .count

    (total_orders.to_f / users.count).round(2)
  end

  def analyze_category_preferences(users)
    Category.joins(products: { line_items: { order: :user } })
           .where(orders: { status: 'completed' })
           .where(users: { id: users.select(:id) })
           .group('categories.name')
           .order('count_all DESC')
           .count
           .first(5)
           .to_h
  end

  def calculate_average_session_duration(users)
    Ahoy::Visit.where(user_id: users.select(:id))
               .where.not(ended_at: nil)
               .average('EXTRACT(EPOCH FROM (ended_at - started_at))')
               .to_i
  end

  def calculate_product_view_rate(users)
    total_views = Ahoy::Event.where(name: 'Product View')
                            .where(user_id: users.select(:id))
                            .count

    (total_views.to_f / users.count).round(2)
  end

  def calculate_cart_addition_rate(users)
    cart_additions = Ahoy::Event.where(name: 'Added to Cart')
                               .where(user_id: users.select(:id))
                               .count

    (cart_additions.to_f / users.count).round(2)
  end

  def calculate_wishlist_usage(users)
    users_with_wishlist = users.joins(:wishlist)
                              .where.not(wishlists: { id: nil })
                              .count

    ((users_with_wishlist.to_f / users.count) * 100).round(2)
  end
end