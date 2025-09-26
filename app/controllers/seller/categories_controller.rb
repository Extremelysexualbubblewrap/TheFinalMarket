# app/controllers/seller/categories_controller.rb
module Seller
  class CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller!

    def index
      @categories = Category.all
    end

    private

    def ensure_seller!
      unless current_user.seller?
        redirect_to root_path, alert: "You need to be a seller to access this area."
      end
    end
  end
end