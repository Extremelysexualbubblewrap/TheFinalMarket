class SellerApplicationsController < ApplicationController
  before_action :require_login
  before_action :check_if_already_seller, only: [:new, :create]

  def new
    @seller_application = SellerApplication.new
  end

  def create
    @seller_application = current_user.seller_applications.build(seller_application_params)
    if @seller_application.save
      flash[:success] = "Your seller application has been submitted."
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def seller_application_params
    params.require(:seller_application).permit(:business_name, :reason_for_selling, :website_or_social_media)
  end

  def check_if_already_seller
    if current_user.gem?
      flash[:warning] = "You are already a seller."
      redirect_to root_path
    end
  end
end

