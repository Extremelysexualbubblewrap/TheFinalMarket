class DisputesController < ApplicationController
  before_action :require_login
  before_action :set_dispute, only: [:show]

  def index
    @disputes = current_user.reported_disputes.order(created_at: :desc)
  end

  def my_disputes
    @disputes = current_user.disputes_against.order(created_at: :desc)
    render :index
  end

  def show
    unless @dispute.reporter == current_user || @dispute.reported_user == current_user ||
           current_user.moderator? || current_user.admin?
      flash[:danger] = "You are not authorized to view this dispute."
      redirect_to disputes_path
    end
  end

  def new
    @dispute = current_user.reported_disputes.build
  end

  def create
    @dispute = current_user.reported_disputes.build(dispute_params)
    
    if @dispute.reported_user == current_user
      flash.now[:danger] = "You cannot report yourself."
      render :new, status: :unprocessable_entity
    elsif @dispute.save
      flash[:success] = "Dispute has been submitted for review."
      redirect_to @dispute
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:id])
  end

  def dispute_params
    params.require(:dispute).permit(:title, :description, :reported_user_id)
  end
end
