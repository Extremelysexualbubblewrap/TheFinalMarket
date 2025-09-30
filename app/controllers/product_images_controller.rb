class ProductImagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :ensure_owner
  before_action :set_product_image, only: [:make_primary, :destroy, :update_position]

  def create
    @product_image = @product.product_images.build(product_image_params)
    
    if @product_image.save
      respond_to do |format|
        format.html { redirect_to @product, notice: 'Image was successfully added.' }
        format.turbo_stream
      end
    else
      redirect_to @product, alert: 'Failed to add image.'
    end
  end

  def make_primary
    @product.product_images.update_all(is_primary: false)
    @product_image.update(is_primary: true)
    
    respond_to do |format|
      format.html { redirect_to @product, notice: 'Primary image updated.' }
      format.turbo_stream
    end
  end

  def update_position
    @product_image.insert_at(params[:position].to_i)
    head :ok
  end

  def destroy
    @product_image.destroy
    
    respond_to do |format|
      format.html { redirect_to @product, notice: 'Image was successfully removed.' }
      format.turbo_stream
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_product_image
    @product_image = @product.product_images.find(params[:id])
  end

  def ensure_owner
    unless @product.user == current_user
      redirect_to @product, alert: 'You are not authorized to manage images for this product.'
    end
  end

  def product_image_params
    params.require(:product_image).permit(:image, :alt_text)
  end
end