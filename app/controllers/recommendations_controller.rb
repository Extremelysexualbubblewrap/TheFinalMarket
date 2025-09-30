class RecommendationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @recommendations = RecommendationService.new(current_user)
                                          .personalized_recommendations(limit: 12)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def recently_viewed
    @products = current_user.product_views
                           .includes(:product)
                           .order(last_viewed_at: :desc)
                           .limit(12)
                           .map(&:product)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def similar_products
    @product = Product.find(params[:product_id])
    @similar_products = Product.joins(:categories, :tags)
                             .where('categories.id IN (?) OR tags.id IN (?)',
                                    @product.category_ids,
                                    @product.tag_ids)
                             .where.not(id: @product.id)
                             .group('products.id')
                             .order('COUNT(DISTINCT categories.id) + COUNT(DISTINCT tags.id) DESC')
                             .limit(6)
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end