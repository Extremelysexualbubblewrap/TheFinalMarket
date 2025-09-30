class RecommendationService
  def initialize(user)
    @user = user
  end

  def personalized_recommendations(limit: 10)
    return [] unless @user

    # Combine different recommendation types with weights
    recommendations = {
      recently_viewed_similar: 0.3,
      category_based: 0.2,
      purchase_history_based: 0.3,
      popular_in_user_segment: 0.2
    }

    results = {}
    
    recommendations.each do |method, weight|
      send(method).each do |product|
        results[product] ||= 0
        results[product] += weight
      end
    end

    # Sort by score and return top N products
    results.sort_by { |_, score| -score }
           .first(limit)
           .map { |product, _| product }
  end

  private

  def recently_viewed_similar
    recent_views = @user.product_views.includes(:product).order(last_viewed_at: :desc).limit(5)
    
    return [] if recent_views.empty?

    # Get similar products based on categories and tags
    product_ids = recent_views.map(&:product_id)
    categories = Product.where(id: product_ids).joins(:categories).pluck('categories.id').uniq
    tags = Product.where(id: product_ids).joins(:tags).pluck('tags.id').uniq

    Product.joins(:categories, :tags)
          .where('categories.id IN (?) OR tags.id IN (?)', categories, tags)
          .where.not(id: product_ids)
          .group('products.id')
          .order('COUNT(DISTINCT categories.id) + COUNT(DISTINCT tags.id) DESC')
          .limit(10)
  end

  def category_based
    return [] unless @user.product_views.exists?

    favorite_categories = @user.product_views
                              .joins(product: :categories)
                              .group('categories.id')
                              .order('COUNT(*) DESC')
                              .limit(3)
                              .pluck('categories.id')

    Product.joins(:categories)
          .where(categories: { id: favorite_categories })
          .where.not(id: @user.product_views.select(:product_id))
          .group('products.id')
          .order('COUNT(*) DESC')
          .limit(10)
  end

  def purchase_history_based
    return [] unless @user.orders.completed.exists?

    # Get categories and tags from past purchases
    purchased_categories = @user.orders.completed
                               .joins(line_items: { product: :categories })
                               .pluck('categories.id').uniq
    
    purchased_tags = @user.orders.completed
                         .joins(line_items: { product: :tags })
                         .pluck('tags.id').uniq

    Product.joins(:categories, :tags)
          .where('categories.id IN (?) OR tags.id IN (?)', purchased_categories, purchased_tags)
          .where.not(id: @user.orders.completed.joins(:line_items).select('line_items.product_id'))
          .group('products.id')
          .order('COUNT(DISTINCT categories.id) + COUNT(DISTINCT tags.id) DESC')
          .limit(10)
  end

  def popular_in_user_segment
    # Find similar users based on shared purchases and views
    similar_users = find_similar_users

    return [] if similar_users.empty?

    # Get popular products among similar users
    Product.joins(:line_items)
          .where(line_items: { order_id: Order.where(user_id: similar_users).completed })
          .where.not(id: @user.product_views.select(:product_id))
          .group('products.id')
          .order('COUNT(*) DESC')
          .limit(10)
  end

  def find_similar_users
    # Find users who bought similar products
    shared_products = @user.orders.completed
                          .joins(:line_items)
                          .pluck('line_items.product_id')

    return [] if shared_products.empty?

    User.joins(orders: :line_items)
        .where(orders: { status: 'completed' })
        .where(line_items: { product_id: shared_products })
        .where.not(id: @user.id)
        .group('users.id')
        .order('COUNT(*) DESC')
        .limit(50)
        .pluck(:id)
  end
end