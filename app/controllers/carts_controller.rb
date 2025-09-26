class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @line_items = @cart.line_items.includes(:product)
  end
end
