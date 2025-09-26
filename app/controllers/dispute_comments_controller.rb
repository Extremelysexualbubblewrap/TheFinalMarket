class DisputeCommentsController < ApplicationController
  before_action :require_login
  before_action :set_dispute

  def create
    @comment = @dispute.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      flash[:success] = "Comment added successfully."
    else
      flash[:danger] = "Error adding comment: #{@comment.errors.full_messages.join(", ")}"
    end

    redirect_to polymorphic_path([:moderator, @dispute])
  end

  private

  def set_dispute
    @dispute = Dispute.find(params[:dispute_id])
    unless @dispute.reporter == current_user || 
           @dispute.reported_user == current_user || 
           current_user.moderator? || 
           current_user.admin?
      flash[:danger] = "You are not authorized to comment on this dispute."
      redirect_to root_path
    end
  end

  def comment_params
    params.require(:dispute_comment).permit(:content)
  end
end
