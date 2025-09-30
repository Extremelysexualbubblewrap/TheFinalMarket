class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review_invitation, only: [:new, :create], if: -> { params[:token].present? }
  before_action :set_reviewable, unless: -> { @review_invitation }
  before_action :set_review, only: [:update, :destroy, :helpful]

  def new
    @review = if @review_invitation
      @review_invitation.build_review(reviewer: current_user)
    else
      @reviewable.reviews.build(reviewer: current_user)
    end
  end

  def create
    @review = if @review_invitation
      @review_invitation.build_review(review_params.merge(
        reviewer: current_user,
        order: @review_invitation.order
      ))
    else
      @reviewable.reviews.build(review_params.merge(reviewer: current_user))
    end

    if @review.save
      @review_invitation&.complete!
      redirect_to review_redirect_path, notice: 'Review was successfully posted.'
    else
      render :new
    end
  end

  def update
    if @review.reviewer == current_user && @review.update(review_params)
      redirect_to review_redirect_path, notice: 'Review was successfully updated.'
    else
      redirect_to review_redirect_path, alert: 'Unable to update review.'
    end
  end

  def destroy
    if @review.reviewer == current_user || current_user.admin?
      @review.destroy
      redirect_to review_redirect_path, notice: 'Review was successfully removed.'
    else
      redirect_to review_redirect_path, alert: 'Unable to remove review.'
    end
  end

  def helpful
    if current_user == @review.reviewer
      redirect_to review_redirect_path, alert: "You cannot mark your own review as helpful."
      return
    end

    if params[:undo] == 'true'
      @review.unhelpful!(current_user)
      message = "Removed helpful mark from review."
    else
      @review.helpful!(current_user)
      message = "Marked review as helpful."
    end

    redirect_to review_redirect_path, notice: message
  end

  private

  def set_review_invitation
    @review_invitation = ReviewInvitation.find_by!(token: params[:token])
    
    if @review_invitation.expired?
      redirect_to root_path, alert: 'This review invitation has expired.'
    elsif @review_invitation.completed?
      redirect_to root_path, alert: 'This item has already been reviewed.'
    elsif @review_invitation.user != current_user
      redirect_to root_path, alert: 'This review invitation is not for you.'
    end

    @reviewable = @review_invitation.item
  end

  def set_reviewable
    if params[:item_id]
      @reviewable = Item.find(params[:item_id])
    elsif params[:user_id]
      @reviewable = User.find(params[:user_id])
    end
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:rating, :content, :pros, :cons)
  end

  def review_redirect_path
    if @review_invitation
      order_path(@review_invitation.order)
    else
      case @reviewable
      when Item
        item_path(@reviewable)
      when User
        user_path(@reviewable)
      else
        root_path
      end
    end
  end
end
