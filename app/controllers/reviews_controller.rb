class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reviewable
  before_action :set_review, only: [:update, :destroy, :helpful]

  def create
    @review = @reviewable.reviews.build(review_params)
    @review.reviewer = current_user

    if @review.save
      redirect_to review_redirect_path, notice: 'Review was successfully posted.'
    else
      redirect_to review_redirect_path, alert: @review.errors.full_messages.join(", ")
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
    params.require(:review).permit(:rating, :content)
  end

  def review_redirect_path
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
