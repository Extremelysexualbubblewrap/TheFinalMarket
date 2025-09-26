# app/controllers/seller/dashboard_controller.rb
module Seller
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller!

    def index
      @recent_orders = current_user.store_orders.recent.limit(5)
      @top_products = current_user.products.top_selling.limit(5)
      @monthly_revenue = current_user.store_orders.monthly_revenue
      @pending_orders_count = current_user.store_orders.pending.count
      @low_stock_products = current_user.products.low_stock.limit(5)
    end

    private

    def ensure_seller!
      unless current_user.seller?
        redirect_to root_path, alert: "You need to be a seller to access this area."
      end
    end
  end
end