class LineItemsController < ApplicationController
  before_action :authenticate_user!

  def create
    product = Product.find(params[:product_id])
    @line_item = @cart.line_items.find_or_initialize_by(product: product)
    
    if @line_item.new_record?
      @line_item.quantity = 1
    else
      @line_item.quantity += 1
    end
    
    if @line_item.save
      redirect_to cart_path, notice: 'Product added to cart.'
    else
      redirect_to product, alert: 'Could not add product to cart.'
    end
  end

  def destroy
    @line_item = @cart.line_items.find(params[:id])
    @line_item.destroy
    redirect_to cart_path, notice: 'Product removed from cart.'
  end
end
