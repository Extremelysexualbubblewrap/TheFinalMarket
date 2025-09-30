class Seller::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_seller
  before_action :set_order, only: [:show, :ship]

  def index
    @orders = current_user.seller_orders.order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def ship
    if @order.update(order_params.merge(status: :shipped))
      # Notify buyer
      NotificationService.notify(
        user: @order.buyer,
        title: "Your order has been shipped!",
        body: "Your order ##{@order.id} has been shipped. Tracking number: #{@order.tracking_number}",
        link: order_path(@order)
      )
      redirect_to seller_order_path(@order), notice: 'Order has been marked as shipped.'
    else
      render :show
    end
  end

  private

  def set_order
    @order = current_user.seller_orders.find(params[:id])
  end

  def authorize_seller
    redirect_to root_path, alert: 'You are not authorized to view this page.' unless current_user.seller?
  end

  def order_params
    params.require(:order).permit(:tracking_number, :shipping_carrier)
  end
end
