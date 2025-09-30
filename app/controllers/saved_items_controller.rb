class SavedItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_saved_item, only: [:destroy, :move_to_cart]

  def index
    @saved_items = current_user.saved_items.includes(product: :variants)
  end

  def create
    @saved_item = current_user.saved_items.build(saved_item_params)
    
    if @saved_item.save
      respond_to do |format|
        format.html { redirect_back(fallback_location: root_path, notice: 'Item saved for later.') }
        format.turbo_stream
      end
    else
      redirect_back(fallback_location: root_path, alert: 'Could not save item.')
    end
  end

  def destroy
    @saved_item.destroy
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, notice: 'Item removed from saved items.') }
      format.turbo_stream
    end
  end

  def move_to_cart
    cart = current_user.cart || current_user.create_cart
    
    line_item = cart.line_items.create(
      product: @saved_item.product,
      variant: @saved_item.variant,
      quantity: 1
    )

    if line_item.persisted?
      @saved_item.destroy
      redirect_back(fallback_location: root_path, notice: 'Item moved to cart.')
    else
      redirect_back(fallback_location: root_path, alert: 'Could not move item to cart.')
    end
  end

  private

  def set_saved_item
    @saved_item = current_user.saved_items.find(params[:id])
  end

  def saved_item_params
    params.require(:saved_item).permit(:product_id, :variant_id, :note)
  end
end