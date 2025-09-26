# app/controllers/seller/analytics_controller.rb
module Seller
  class AnalyticsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller!

    def index
      @revenue_by_day = current_user.store_orders
                                    .group_by_day(:created_at)
                                    .sum(:total)
      
      @top_selling_products = current_user.products
                                          .top_selling
                                          .limit(5)
                                          .pluck(:name, :total_sales)
      
      @orders_by_status = current_user.store_orders
                                      .group(:status)
                                      .count
    end

    private

    def ensure_seller!
      unless current_user.seller?
        redirect_to root_path, alert: "You need to be a seller to access this area."
      end
    end
  end
end