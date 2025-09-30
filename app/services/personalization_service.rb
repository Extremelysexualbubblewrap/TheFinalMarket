class PersonalizationService
  def initialize(user)
    @user = user
    @redis = Redis.new
    @cache_duration = 24.hours
  end

  def personalized_recommendations
    Rails.cache.fetch("user_#{@user.id}_recommendations", expires_in: @cache_duration) do
      {
        recently_viewed: get_recently_viewed,
        recommended_products: get_recommended_products,
        trending_in_categories: get_trending_in_user_categories,
        similar_to_purchased: get_similar_to_purchased,
        flash_sales: get_relevant_flash_sales
      }
    end
  end

  private

  def get_recently_viewed
    @user.viewed_products
         .order(viewed_at: :desc)
         .limit(10)
         .includes(:categories, :reviews)
  end

  def get_recommended_products
    category_weights = calculate_category_weights
    product_scores = {}

    Product.active.find_each do |product|
      score = calculate_product_score(product, category_weights)
      product_scores[product.id] = score if score > 0
    end

    product_ids = product_scores.sort_by { |_, score| -score }
                               .first(10)
                               .map(&:first)

    Product.where(id: product_ids)
           .includes(:categories, :reviews)
  end

  def get_trending_in_user_categories
    user_categories = @user.favorite_categories + 
                     @user.purchased_products.flat_map(&:categories)

    trending_products = user_categories.uniq.map do |category|
      {
        category: category,
        products: category.products
                         .trending
                         .limit(5)
                         .includes(:reviews)
      }
    end

    trending_products.sort_by { |tp| -tp[:products].sum(&:trending_score) }
  end

  def get_similar_to_purchased
    purchased_products = @user.purchased_products.recent

    similar_products = purchased_products.flat_map do |product|
      product.similar_products
             .limit(5)
             .includes(:categories, :reviews)
    end

    similar_products.uniq.take(10)
  end

  def get_relevant_flash_sales
    FlashSale.active
             .joins(:product)
             .where(products: { category_id: @user.interested_category_ids })
             .includes(product: [:categories, :reviews])
             .limit(5)
  end

  def calculate_category_weights
    weights = Hash.new(0)
    
    # Viewed products weight
    @user.product_views.each do |view|
      view.product.categories.each do |category|
        weights[category.id] += 1 * recency_factor(view.viewed_at)
      end
    end

    # Purchased products weight (higher weight)
    @user.purchased_products.each do |product|
      product.categories.each do |category|
        weights[category.id] += 3 * recency_factor(product.purchased_at)
      end
    end

    # Saved items weight
    @user.saved_items.each do |item|
      item.categories.each do |category|
        weights[category.id] += 2
      end
    end

    # Normalize weights
    max_weight = weights.values.max.to_f
    weights.transform_values { |w| w / max_weight }
  end

  def calculate_product_score(product, category_weights)
    return 0 if product.user_id == @user.id # Don't recommend own products
    return 0 if @user.purchased_products.include?(product) # Don't recommend already purchased

    score = 0
    
    # Category match score
    product.categories.each do |category|
      score += category_weights[category.id] * 0.4
    end

    # Rating score
    score += (product.average_rating / 5.0) * 0.2

    # Price range match score
    score += price_range_match_score(product) * 0.2

    # Freshness score
    score += freshness_score(product) * 0.1

    # Popularity score
    score += popularity_score(product) * 0.1

    score
  end

  def recency_factor(timestamp)
    days_ago = (Time.current - timestamp).to_i / 1.day
    Math.exp(-0.1 * days_ago) # Exponential decay
  end

  def price_range_match_score(product)
    user_avg_price = @user.purchased_products.average(:price) || 0
    price_diff_ratio = (product.price - user_avg_price).abs / user_avg_price
    Math.exp(-price_diff_ratio) # Score decreases exponentially with price difference
  end

  def freshness_score(product)
    days_old = (Time.current - product.created_at).to_i / 1.day
    Math.exp(-0.05 * days_old) # Gradual decay based on age
  end

  def popularity_score(product)
    views = product.view_count || 0
    purchases = product.purchase_count || 0
    saves = product.saved_count || 0
    
    # Normalize each metric to 0-1 range
    max_views = Product.maximum(:view_count) || 1
    max_purchases = Product.maximum(:purchase_count) || 1
    max_saves = Product.maximum(:saved_count) || 1

    normalized_score = (
      (views.to_f / max_views) * 0.3 +
      (purchases.to_f / max_purchases) * 0.5 +
      (saves.to_f / max_saves) * 0.2
    )

    normalized_score
  end
end