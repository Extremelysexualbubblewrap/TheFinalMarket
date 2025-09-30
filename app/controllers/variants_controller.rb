class VariantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_variant, only: [:edit, :update, :destroy]
  before_action :ensure_owner

  def new
    @variant = @product.variants.build
    @option_types = @product.option_types.includes(:option_values)
  end

  def create
    @variant = @product.variants.build(variant_params)
    
    if @variant.save
      redirect_to @product, notice: 'Variant was successfully created.'
    else
      @option_types = @product.option_types.includes(:option_values)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @option_types = @product.option_types.includes(:option_values)
  end

  def update
    if @variant.update(variant_params)
      redirect_to @product, notice: 'Variant was successfully updated.'
    else
      @option_types = @product.option_types.includes(:option_values)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @variant.destroy
    redirect_to @product, notice: 'Variant was successfully deleted.'
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_variant
    @variant = @product.variants.find(params[:id])
  end

  def ensure_owner
    unless @product.user == current_user
      redirect_to @product, alert: 'You are not authorized to manage variants for this product.'
    end
  end

  def variant_params
    params.require(:variant).permit(
      :price,
      :stock_quantity,
      :image,
      option_value_ids: []
    )
  end
end