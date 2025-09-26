class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_item, only: [:update, :destroy]

  def index
    @cart_items = current_user.cart_items.includes(:item)
    @total = current_user.cart_total
  end

  def create
    @item = Item.find(params[:item_id])
    result = current_user.add_to_cart(@item, params[:quantity].to_i)

    if result.persisted?
      redirect_to cart_items_path, notice: 'Item added to cart successfully.'
    else
      redirect_to @item, alert: result.errors.full_messages.join(', ')
    end
  end

  def update
    if @cart_item.update(cart_item_params)
      redirect_to cart_items_path, notice: 'Cart updated successfully.'
    else
      redirect_to cart_items_path, alert: @cart_item.errors.full_messages.join(', ')
    end
  end

  def destroy
    @cart_item.destroy
    redirect_to cart_items_path, notice: 'Item removed from cart.'
  end

  def clear
    current_user.clear_cart
    redirect_to cart_items_path, notice: 'Cart cleared.'
  end

  private

  def set_cart_item
    @cart_item = current_user.cart_items.find(params[:id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end