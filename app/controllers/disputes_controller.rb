class DisputesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:new, :create]
  before_action :set_dispute, except: [:index, :new, :create]
  before_action :authorize_dispute_action

  def index
    @disputes = if current_user.moderator? || current_user.admin?
      Dispute.all
    else
      Dispute.where(buyer: current_user).or(Dispute.where(seller: current_user))
    end.includes(:buyer, :seller, :order, :evidence, :resolution)
      .order(created_at: :desc)
  end

  def show
    @evidence = @dispute.evidence.includes(:user).order(created_at: :desc)
    @comments = @dispute.comments.includes(:user).order(created_at: :desc)
  end

  def new
    @dispute = Dispute.new(
      order: @order,
      buyer: @order.buyer,
      seller: @order.seller,
      amount: @order.total_amount,
      escrow_transaction: @order.escrow_transaction
    )
  end

  def create
    @dispute = Dispute.new(dispute_params)
    @dispute.buyer = @order.buyer
    @dispute.seller = @order.seller
    @dispute.escrow_transaction = @order.escrow_transaction

    if @dispute.save
      redirect_to @dispute, notice: 'Dispute was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def add_evidence
    @evidence = @dispute.add_evidence(
      current_user,
      evidence_params
    )

    if @evidence.persisted?
      redirect_to @dispute, notice: 'Evidence was successfully added.'
    else
      redirect_to @dispute, alert: 'Failed to add evidence.'
    end
  end

  def assign_moderator
    unless current_user.moderator? || current_user.admin?
      redirect_to @dispute, alert: 'Unauthorized action'
      return
    end

    if @dispute.assign_to_moderator(current_user)
      redirect_to @dispute, notice: 'You have been assigned as moderator.'
    else
      redirect_to @dispute, alert: 'Failed to assign moderator.'
    end
  end

  def resolve
    unless @dispute.moderator == current_user || current_user.admin?
      redirect_to @dispute, alert: 'Unauthorized action'
      return
    end

    if @dispute.resolve(resolution_params)
      redirect_to @dispute, notice: 'Dispute has been resolved.'
    else
      redirect_to @dispute, alert: 'Failed to resolve dispute.'
    end
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
  end

  def set_dispute
    @dispute = Dispute.find(params[:id])
  end

  def authorize_dispute_action
    case action_name
    when 'index'
      # All authenticated users can view their disputes
      true
    when 'show'
      authorize_dispute_view
    when 'new', 'create'
      authorize_dispute_creation
    when 'add_evidence'
      authorize_evidence_addition
    when 'assign_moderator'
      authorize_moderator_assignment
    when 'resolve'
      authorize_dispute_resolution
    end
  end

  def authorize_dispute_view
    unless @dispute.can_participate?(current_user)
      redirect_to root_path, alert: 'Unauthorized access'
    end
  end

  def authorize_dispute_creation
    unless @order.buyer == current_user || @order.seller == current_user
      redirect_to root_path, alert: 'Unauthorized access'
    end
  end

  def authorize_evidence_addition
    unless @dispute.can_participate?(current_user)
      redirect_to @dispute, alert: 'Unauthorized action'
    end
  end

  def authorize_moderator_assignment
    unless current_user.moderator? || current_user.admin?
      redirect_to @dispute, alert: 'Unauthorized action'
    end
  end

  def authorize_dispute_resolution
    unless @dispute.moderator == current_user || current_user.admin?
      redirect_to @dispute, alert: 'Unauthorized action'
    end
  end

  def dispute_params
    params.require(:dispute).permit(
      :title,
      :description,
      :dispute_type,
      :amount
    )
  end

  def evidence_params
    params.require(:evidence).permit(
      :title,
      :description,
      :attachment
    )
  end

  def resolution_params
    params.require(:resolution).permit(
      :resolution_type,
      :notes,
      :refund_amount
    )
  end
end
