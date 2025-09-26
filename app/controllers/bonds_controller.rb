class BondsController < ApplicationController
  before_action :require_login
  before_action :check_bond_status

  def new
  end

  def create
    # In a real application, you would integrate with a payment gateway like Stripe.
    # For this example, we'll simulate a successful payment.
    if current_user.update(seller_status: :active)
      flash[:success] = "Bond paid successfully! You are now a verified seller."
      redirect_to root_path
    else
      flash[:danger] = "There was an error processing your bond payment."
      render :new
    end
  end

  private

  def check_bond_status
    unless current_user.awaiting_bond?
      flash[:warning] = "You do not need to pay a bond at this time."
      redirect_to root_path
    end
  end
end

