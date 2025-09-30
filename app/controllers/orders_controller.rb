class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :update]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def show
  end

  def new
    @cart_items = current_user.cart_items.includes(:item)
    if @cart_items.empty?
      redirect_to cart_items_path, alert: "Your cart is empty!"
      return
    end
    @order = Order.new
    @total = current_user.cart_total
  end

  def create
    @order = current_user.orders.build(order_params)
    @order.total_amount = current_user.cart_total

    # Build order items from cart items
    current_user.cart_items.each do |cart_item|
      @order.order_items.build(
        item: cart_item.item,
        quantity: cart_item.quantity,
        unit_price: cart_item.item.price
      )
    end

    if @order.save
      @order.order_items.each do |order_item|
        ReviewInvitation.create!(
          order: @order,
          user: current_user,
          item: order_item.item
        )
      end

      # Clear the cart after successful order
      current_user.cart_items.destroy_all
      
      redirect_to @order, notice: 'Order was successfully created. Check your email for review invitations!'
    else
      @cart_items = current_user.cart_items.includes(:item)
      @total = current_user.cart_total
      render :new
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render :show
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:shipping_address, :notes)
  end
end