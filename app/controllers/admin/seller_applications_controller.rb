class Admin::SellerApplicationsController < Admin::BaseController
  def index
    @seller_applications = SellerApplication.where(status: :pending)
  end

  def show
    @seller_application = SellerApplication.find(params[:id])
  end

  def update
    @seller_application = SellerApplication.find(params[:id])
    if @seller_application.update(seller_application_params)
      if @seller_application.approved?
        @seller_application.user.update(user_type: :gem, seller_status: :awaiting_bond)
      end
      flash[:success] = "Seller application updated."
      redirect_to admin_seller_applications_path
    else
      render :show
    end
  end

  private

  def seller_application_params
    params.require(:seller_application).permit(:status, :feedback)
  end
end
