class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :update, :toggle_role]

  def index
    @users = User.order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def update
    if @user.update(user_params)
      flash[:success] = "User updated successfully"
      redirect_to admin_user_path(@user)
    else
      flash.now[:danger] = "Error updating user"
      render :show
    end
  end

  def toggle_role
    new_role = params[:role]
    if User.roles.keys.include?(new_role)
      @user.update(role: new_role)
      flash[:success] = "User role updated to #{new_role}"
    else
      flash[:danger] = "Invalid role specified"
    end
    redirect_to admin_user_path(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
