class Admin::DisputesController < Admin::BaseController
  before_action :set_dispute, only: [:show, :assign_moderator, :post_comment, :resolve]

  def index
    @disputes = Dispute.includes(:buyer, :seller, :moderator).order(created_at: :desc).page(params[:page])
  end

  def show
    @dispute_comments = @dispute.dispute_comments.includes(:user).order(created_at: :asc)
  end

  def assign_moderator
    moderator = User.find(params[:moderator_id])
    if @dispute.update(moderator: moderator, status: :under_review)
      redirect_to admin_dispute_path(@dispute), notice: "Moderator assigned successfully."
    else
      redirect_to admin_dispute_path(@dispute), alert: "Failed to assign moderator."
    end
  end

  def post_comment
    @comment = @dispute.dispute_comments.new(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to admin_dispute_path(@dispute), notice: "Comment posted successfully."
    else
      render :show
    end
  end

  def resolve
    resolution = params.dig(:dispute, :resolution)
    if DisputeResolutionService.new(@dispute, current_user).resolve(resolution)
      redirect_to admin_dispute_path(@dispute), notice: "Dispute has been resolved."
    else
      redirect_to admin_dispute_path(@dispute), alert: "Failed to resolve dispute."
    end
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:id])
  end

  def comment_params
    params.require(:dispute_comment).permit(:body)
  end
end
