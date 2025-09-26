# app/controllers/seller/products_controller.rb
module Seller
  class ProductsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_seller!
    before_action :set_product, only: [:show, :edit, :update, :destroy]

    def index
      @products = current_user.products
                            .includes(image_attachment: :blob)
                            .order(position: :asc)
                            .page(params[:page])
    end

    def batch_update
      case params[:operation]
      when 'reorder'
        reorder_products
      when 'update_prices'
        update_product_prices
      when 'update_stock'
        update_product_stock
      when 'archive'
        archive_products
      when 'assign_category'
        assign_category
      end

      head :ok
    end

    def update
      if @product.update(product_params)
        respond_to do |format|
          format.html { redirect_to seller_products_path, notice: 'Product updated successfully' }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.turbo_stream { render turbo_stream: turbo_stream.replace(@product, partial: 'product', locals: { product: @product }) }
        end
      end
    end

    private

    def set_product
      @product = current_user.products.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price, :stock, :position, :status, :category_id, :image)
    end

    def reorder_products
      params[:positions].each do |id, position|
        current_user.products.find(id).update(position: position)
      end
    end

    def update_product_prices
      adjustment = params[:adjustment].to_f
      operation = params[:adjustment_type]

      selected_products = current_user.products.where(id: params[:product_ids])
      
      selected_products.each do |product|
        new_price = case operation
                   when 'percentage'
                     product.price * (1 + adjustment / 100)
                   when 'fixed'
                     product.price + adjustment
                   end
        product.update(price: new_price)
      end
    end

    def update_product_stock
      adjustment = params[:adjustment].to_i
      selected_products = current_user.products.where(id: params[:product_ids])
      
      selected_products.each do |product|
        new_stock = product.stock + adjustment
        product.update(stock: new_stock) if new_stock >= 0
      end
    end

    def archive_products
      current_user.products.where(id: params[:product_ids]).update_all(status: 'archived')
    end

    def assign_category
      category = Category.find(params[:category_id])
      current_user.products.where(id: params[:product_ids]).update_all(category_id: category.id)
    end

    def ensure_seller!
      unless current_user.seller?
        redirect_to root_path, alert: "You need to be a seller to access this area."
      end
    end
  end
end