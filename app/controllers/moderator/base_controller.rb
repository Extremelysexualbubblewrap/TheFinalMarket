class Moderator::BaseController < ApplicationController
  before_action :require_moderator
  layout 'moderator'

  private

  def require_moderator
    unless current_user&.moderator? || current_user&.admin?
      flash[:danger] = "You are not authorized to access this area."
      redirect_to root_path
    end
  end
end