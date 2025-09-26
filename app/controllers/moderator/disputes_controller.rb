class Moderator::DisputesController < Moderator::BaseController
  before_action :set_dispute, except: [:index]

  def index
    @disputes = Dispute.includes(:reporter, :reported_user, :moderator)
                      .order(created_at: :desc)
    
    # Filter options
    @disputes = @disputes.where(status: params[:status]) if params[:status].present?
    @disputes = @disputes.unassigned if params[:unassigned] == 'true'
    @disputes = @disputes.where(moderator: current_user) if params[:my_cases] == 'true'
  end

  def show
  end

  def assign
    if @dispute.moderator.present?
      flash[:danger] = "This dispute is already assigned to a moderator."
    else
      @dispute.assign_to_moderator(current_user)
      flash[:success] = "You have been assigned to this dispute."
    end
    redirect_to moderator_dispute_path(@dispute)
  end

  def update
    if @dispute.update(dispute_params)
      flash[:success] = "Dispute updated successfully."
      redirect_to moderator_dispute_path(@dispute)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def resolve
    if @dispute.resolve(params[:resolution_notes])
      flash[:success] = "Dispute has been marked as resolved."
      redirect_to moderator_disputes_path
    else
      flash[:danger] = "Unable to resolve dispute: #{@dispute.errors.full_messages.join(", ")}"
      redirect_to moderator_dispute_path(@dispute)
    end
  end

  def dismiss
    if @dispute.dismiss(params[:resolution_notes])
      flash[:success] = "Dispute has been dismissed."
      redirect_to moderator_disputes_path
    else
      flash[:danger] = "Unable to dismiss dispute: #{@dispute.errors.full_messages.join(", ")}"
      redirect_to moderator_dispute_path(@dispute)
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:id])
  end

  def dispute_params
    params.require(:dispute).permit(:status, :resolution_notes)
  end
end
