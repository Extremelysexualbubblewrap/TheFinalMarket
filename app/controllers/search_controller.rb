class SearchController < ApplicationController
  def index
    @q = Product.ransack(params[:q])
    
    # Use Elasticsearch for text search if search query is present
    if params[:search].present?
      @search_results = Product.search_with_analytics(
        query: params[:search],
        page: params[:page] || 1,
        per_page: params[:per_page] || 20,
        user: current_user
      )
      base_products = Product.where(id: @search_results.pluck(:id))
    else
      base_products = Product.all
    end

    # Apply Ransack filters to the base products
    @products = @q.result(distinct: true)
                 .merge(base_products)
                 .page(params[:page])
                 .per(params[:per_page] || 20)

    respond_to do |format|
      format.html
      format.json { render json: @products }
      format.turbo_stream
    end
  end

  def suggestions
    render json: Rails.cache.fetch("search_suggestions:#{params[:q].downcase}", expires_in: 1.day) do
      Product.search_with_analytics(query: params[:q], per_page: 0)[:suggestions]
    end
  end

  private

  def search_params
    params.fetch(:q, {}).permit(
      :name_cont, :brand_eq, :price_gteq, :price_lteq,
      :created_at_gteq, :created_at_lteq,
      :status_eq, :availability_eq,
      { category_ids_in: [], tag_ids_in: [] },
      :s # Sort parameter
    )
  end
end