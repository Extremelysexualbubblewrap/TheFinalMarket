class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist
  before_action :set_product, only: [:add_item, :remove_item]

  def show
    @wishlist_items = @wishlist.wishlist_items.includes(product: [:user, :variants])
  end

  def add_item
    if @wishlist.add_product(@product)
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, notice: 'Product added to wishlist.') }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("wishlist_button_#{@product.id}", 
          partial: 'products/wishlist_button', 
          locals: { product: @product }) }
      end
    else
      redirect_back(fallback_location: root_path, alert: 'Could not add product to wishlist.')
    end
  end

  def remove_item
    @wishlist.remove_product(@product)
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, notice: 'Product removed from wishlist.') }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("wishlist_button_#{@product.id}", 
        partial: 'products/wishlist_button', 
        locals: { product: @product }) }
    end
  end

  private

  def set_wishlist
    @wishlist = current_user.wishlist || current_user.create_wishlist
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end