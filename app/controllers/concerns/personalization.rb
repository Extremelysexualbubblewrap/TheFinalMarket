module Personalization
  extend ActiveSupport::Concern

  included do
    before_action :track_user_activity
    helper_method :personalized_content
  end

  private

  def track_user_activity
    return unless user_signed_in?

    Ahoy.track "Page View", {
      controller: controller_name,
      action: action_name,
      params: filtered_params
    }

    track_product_view if @product.present?
    track_category_view if @category.present?
  end

  def track_product_view
    ProductView.create_or_update!(
      user: current_user,
      product: @product,
      viewed_at: Time.current
    )
  end

  def track_category_view
    CategoryView.create_or_update!(
      user: current_user,
      category: @category,
      viewed_at: Time.current
    )
  end

  def personalized_content
    return {} unless user_signed_in?

    Rails.cache.fetch("user_#{current_user.id}_personalized_content", expires_in: 1.hour) do
      PersonalizationService.new(current_user).personalized_recommendations
    end
  end

  def filtered_params
    params.except(:controller, :action, :utf8, :authenticity_token).to_unsafe_h
  end
end