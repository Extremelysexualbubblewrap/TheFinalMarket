class DealsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:category_deals]

  def index
    @recommendations = PersonalizationService.new(current_user).personalized_recommendations
    @flash_sales = @recommendations[:flash_sales]
    @recommended_deals = @recommendations[:recommended_products].on_sale
    @trending_deals = @recommendations[:trending_in_categories].map do |category_data|
      {
        category: category_data[:category],
        products: category_data[:products].on_sale
      }
    end
  end

  def category_deals
    @deals = @category.products.on_sale.includes(:reviews)
    
    # Notify user about deals in their favorite category
    if current_user.favorite_categories.include?(@category)
      PushNotificationService.notify_user(
        current_user,
        title: "New Deals in #{@category.name}!",
        body: "Check out the latest deals in your favorite category!",
        url: category_deals_path(@category),
        actions: [
          { action: "view_deals", title: "View Deals" },
          { action: "remind_later", title: "Remind Later" }
        ]
      )
    end
  end

  def flash_sale
    @flash_sale = FlashSale.find(params[:id])
    @product = @flash_sale.product
    @similar_products = PersonalizationService.new(current_user)
                         .personalized_recommendations[:similar_to_purchased]
                         .where(id: @flash_sale.similar_product_ids)

    # Notify user if this is in their interests
    if current_user.interested_in_product?(@product)
      PushNotificationService.notify_user(
        current_user,
        title: "Flash Sale Alert!",
        body: "#{@product.name} is on flash sale! Limited time only!",
        url: flash_sale_path(@flash_sale),
        actions: [
          { action: "view_sale", title: "View Sale" },
          { action: "add_to_cart", title: "Add to Cart" }
        ]
      )
    end
  end

  private

  def set_category
    @category = Category.find(params[:category_id])
  end
end