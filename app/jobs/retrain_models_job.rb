class RetrainModelsJob < ApplicationJob
  queue_as :machine_learning

  def perform(models: ['all'], user_id: nil)
    start_time = Time.current
    results = {}

    models = available_models if models.include?('all')

    models.each do |model|
      results[model] = train_model(model)
    end

    # Cache results
    Rails.cache.write('ml_models_metadata', {
      last_trained_at: start_time,
      training_duration: Time.current - start_time,
      model_accuracies: results
    })

    # Notify admin
    notify_completion(user_id, results) if user_id.present?
  end

  private

  def available_models
    [
      'sales_forecast',
      'inventory_prediction',
      'customer_behavior',
      'churn_prediction',
      'product_trends',
      'category_performance'
    ]
  end

  def train_model(model)
    case model
    when 'sales_forecast'
      train_sales_forecast_model
    when 'inventory_prediction'
      train_inventory_prediction_model
    when 'customer_behavior'
      train_customer_behavior_model
    when 'churn_prediction'
      train_churn_prediction_model
    when 'product_trends'
      train_product_trends_model
    when 'category_performance'
      train_category_performance_model
    end
  end

  def train_sales_forecast_model
    # Gather historical sales data
    historical_data = Order.completed
                         .where('created_at > ?', 2.years.ago)
                         .group_by_day(:created_at)
                         .sum(:total_amount)

    # Prepare features and target
    data = {
      dates: historical_data.keys,
      values: historical_data.values
    }

    # Train time series model
    model = MachineLearningService.train_model(data, model_type: :time_series)

    # Cache the model
    Rails.cache.write('ml_model:sales_forecast', model)

    {
      accuracy: model[:accuracy],
      training_samples: historical_data.size
    }
  end

  def train_inventory_prediction_model
    products = Product.includes(:line_items, :variants).all
    training_data = products.map do |product|
      {
        features: extract_inventory_features(product),
        target: calculate_optimal_stock(product)
      }
    end

    # Train linear regression model
    model = MachineLearningService.train_model(
      { features: training_data.map { |d| d[:features] },
        target: training_data.map { |d| d[:target] } },
      model_type: :linear_regression
    )

    Rails.cache.write('ml_model:inventory_prediction', model)

    {
      accuracy: model[:r_squared],
      training_samples: products.size
    }
  end

  def train_customer_behavior_model
    users = User.includes(:orders, :product_views).all
    training_data = users.map do |user|
      {
        features: extract_user_features(user),
        target: calculate_user_value(user)
      }
    end

    # Train clustering model for segmentation
    segmentation_model = MachineLearningService.train_model(
      { points: training_data.map { |d| d[:features] }, k: 5 },
      model_type: :clustering
    )

    Rails.cache.write('ml_model:customer_behavior', segmentation_model)

    {
      silhouette_score: segmentation_model[:silhouette_score],
      training_samples: users.size
    }
  end

  def train_churn_prediction_model
    users = User.includes(:orders, :reviews, :support_tickets).all
    training_data = users.map do |user|
      {
        features: extract_churn_features(user),
        target: user_churned?(user)
      }
    end

    # Train logistic regression model
    model = MachineLearningService.train_model(
      { features: training_data.map { |d| d[:features] },
        target: training_data.map { |d| d[:target] } },
      model_type: :logistic_regression
    )

    Rails.cache.write('ml_model:churn_prediction', model)

    {
      accuracy: model[:accuracy],
      training_samples: users.size
    }
  end

  def notify_completion(user_id, results)
    user = User.find(user_id)
    AdminMailer.model_training_complete(user, results).deliver_later
  end

  private

  def extract_inventory_features(product)
    [
      product.line_items.sum(:quantity), # Total units sold
      product.line_items.average(:quantity)&.to_f || 0, # Average order size
      product.variants.sum(:stock_quantity), # Current stock
      product.price, # Price
      product.reviews.average(:rating)&.to_f || 0, # Average rating
      product.views_count # View count
    ]
  end

  def calculate_optimal_stock(product)
    # Calculate based on historical sales and lead time
    monthly_sales = product.line_items
                          .joins(:order)
                          .where(orders: { status: 'completed' })
                          .where('orders.created_at > ?', 1.month.ago)
                          .sum(:quantity)
    
    lead_time = 14 # Assume 14 days lead time
    safety_stock = monthly_sales * 0.2 # 20% safety stock

    (monthly_sales / 30.0) * lead_time + safety_stock
  end

  def extract_user_features(user)
    [
      user.orders.count, # Number of orders
      user.orders.average(:total_amount)&.to_f || 0, # Average order value
      user.product_views.count, # Number of product views
      (user.orders.maximum(:created_at) - user.created_at).to_i, # Days as customer
      user.reviews.count # Number of reviews
    ]
  end

  def calculate_user_value(user)
    user.orders.sum(:total_amount)
  end

  def extract_churn_features(user)
    last_order = user.orders.maximum(:created_at)
    days_since_last_order = last_order ? (Time.current - last_order).to_i / 86400 : 365
    
    [
      days_since_last_order,
      user.orders.count,
      user.orders.average(:total_amount)&.to_f || 0,
      user.support_tickets.count,
      user.reviews.average(:rating)&.to_f || 0
    ]
  end

  def user_churned?(user)
    return 1 if user.orders.empty?
    last_order = user.orders.maximum(:created_at)
    (Time.current - last_order).to_i / 86400 > 180 ? 1 : 0 # Consider churned if no order in 6 months
  end
end