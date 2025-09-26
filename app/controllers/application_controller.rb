class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  include AuthenticationConcern
  include Pundit::Authorization

  before_action :set_cart

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart if user_signed_in?
  end
end
