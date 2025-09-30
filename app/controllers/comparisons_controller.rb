class ComparisonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_compare_list
  before_action :set_product, only: [:add_item, :remove_item]

  def show
    @comparison_data = ProductComparisonService.new(@compare_list.products).compare_attributes
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def add_item
    @compare_item = @compare_list.compare_items.build(product: @product)
    
    if @compare_item.save
      respond_to do |format|
        format.html { redirect_back fallback_location: @product, notice: 'Product added to comparison.' }
        format.turbo_stream
      end
    else
      error_message = @compare_item.errors.full_messages.join(', ')
      respond_to do |format|
        format.html { redirect_back fallback_location: @product, alert: error_message }
        format.turbo_stream { render turbo_stream: turbo_stream.update('flash', error_message) }
      end
    end
  end

  def remove_item
    @compare_item = @compare_list.compare_items.find_by(product: @product)
    @compare_item&.destroy
    
    respond_to do |format|
      format.html { redirect_back fallback_location: comparisons_path, notice: 'Product removed from comparison.' }
      format.turbo_stream
    end
  end

  def clear
    @compare_list.compare_items.destroy_all
    
    respond_to do |format|
      format.html { redirect_to products_path, notice: 'Comparison list cleared.' }
      format.turbo_stream { render turbo_stream: turbo_stream.replace('compare_list', partial: 'empty_state') }
    end
  end

  private

  def set_compare_list
    @compare_list = current_user.compare_list || current_user.create_compare_list
  end

  def set_product
    @product = Product.find(params[:product_id])
  end
end