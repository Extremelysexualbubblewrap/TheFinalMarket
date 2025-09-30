class ProductsController < ApplicationController
  include AbTestable
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_product, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]

  def index
    @categories = Category.all
    @tags = Tag.all
    @search_params = search_params
    
    # A/B test the product listing layout
    @grid_layout = ab_test(
      "product_grid_layout",
      "standard",
      "compact",
      "gallery"
    )
    
    # A/B test the sorting options
    @default_sort = ab_test(
      "product_default_sort",
      "newest",
      "popular",
      "price_asc"
    )
    
    @products = ProductSearch.new(@search_params.merge(sort: @default_sort)).search
    @products = @products.page(params[:page]).per(12)

    respond_to do |format|
      format.html
      format.turbo_stream if turbo_frame_request?
    end
  end

  def show
    # A/B test the product page layout
    @layout_variant = ab_test(
      "product_page_layout",
      "standard",
      "immersive",
      "minimal"
    )
    
    # A/B test pricing display
    @price_display = ab_test(
      "product_price_display",
      "standard",
      "with_savings",
      "with_comparison"
    )

    if user_signed_in?
      product_view = current_user.product_views.find_or_initialize_by(product: @product)
      product_view.view_count += 1
      product_view.last_viewed_at = Time.current
      product_view.save
    end

    @similar_products = RecommendationService.new(current_user)
                         .similar_products(@product)
                         .limit(6)

    # Track view for A/B test
    ab_finished("product_page_layout", "viewed")
    ab_finished("product_price_display", "viewed")
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = current_user.products.build(product_params)
    
    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Product was successfully deleted.'
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def search_params
    params.permit(
      :query, :category_id, :min_price, :max_price, 
      :min_rating, :in_stock, :sort_by, tag_ids: []
    )
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :image, category_ids: [])
  end

  def ensure_owner
    unless @product.user == current_user
      redirect_to products_url, alert: 'You are not authorized to perform this action.'
    end
  end
end
