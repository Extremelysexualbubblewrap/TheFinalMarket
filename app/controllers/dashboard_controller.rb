class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_seller

  def overview
    @user = current_user
    @dashboard = DashboardDecorator.new(@user)
  end

  def payment_history
    @transactions = current_user.payment_transactions.order(created_at: :desc).page(params[:page])
  end

  def escrow
    @escrow_transactions = current_user.escrow_transactions.order(created_at: :desc).page(params[:page])
  end

  def bond
    @bond = current_user.bond
    @bond_transactions = @bond&.bond_transactions&.order(created_at: :desc)
  end

  private

  def authorize_seller
    redirect_to root_path, alert: 'You are not authorized to view this page.' unless current_user.seller?
  end
end
