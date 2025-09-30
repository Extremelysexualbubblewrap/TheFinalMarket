class ProductSearch
  attr_reader :products

  def initialize(params = {})
    @params = params
    @products = Product.all.includes(:user, :categories, :tags)
  end

  def search
    search_by_query if @params[:query].present?
    filter_by_category if @params[:category_id].present?
    filter_by_tags if @params[:tag_ids].present?
    filter_by_price_range if @params[:min_price].present? || @params[:max_price].present?
    filter_by_rating if @params[:min_rating].present?
    filter_by_availability if @params[:in_stock].present?
    sort_results if @params[:sort_by].present?
    
    @products
  end

  private

  def search_by_query
    query = "%#{@params[:query]}%"
    @products = @products.where("products.name ILIKE ? OR products.description ILIKE ?", query, query)
  end

  def filter_by_category
    @products = @products.joins(:categories).where(categories: { id: @params[:category_id] })
  end

  def filter_by_tags
    @products = @products.joins(:tags).where(tags: { id: @params[:tag_ids] })
  end

  def filter_by_price_range
    @products = @products.where("price >= ?", @params[:min_price]) if @params[:min_price].present?
    @products = @products.where("price <= ?", @params[:max_price]) if @params[:max_price].present?
  end

  def filter_by_rating
    @products = @products
      .left_joins(:reviews)
      .group("products.id")
      .having("COALESCE(AVG(reviews.rating), 0) >= ?", @params[:min_rating])
  end

  def filter_by_availability
    if ActiveRecord::Type::Boolean.new.cast(@params[:in_stock])
      @products = @products.where("stock_quantity > 0")
        .or(Product.joins(:variants).where("variants.stock_quantity > 0"))
    end
  end

  def sort_results
    case @params[:sort_by]
    when "price_asc"
      @products = @products.order(price: :asc)
    when "price_desc"
      @products = @products.order(price: :desc)
    when "newest"
      @products = @products.order(created_at: :desc)
    when "rating"
      @products = @products
        .left_joins(:reviews)
        .group("products.id")
        .order("COALESCE(AVG(reviews.rating), 0) DESC")
    when "popularity"
      @products = @products
        .left_joins(:line_items)
        .group("products.id")
        .order("COUNT(line_items.id) DESC")
    end
  end
end