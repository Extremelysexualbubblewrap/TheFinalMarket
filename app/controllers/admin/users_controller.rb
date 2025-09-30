class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :update, :toggle_role, :suspend, :warn, :verify_seller]

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

  def suspend
    if UserManagementService.new(@user, current_user).suspend(params[:reason])
      redirect_to admin_user_path(@user), notice: 'User has been suspended.'
    else
      redirect_to admin_user_path(@user), alert: 'Failed to suspend user.'
    end
  end

  def warn
    if UserManagementService.new(@user, current_user).warn(params[:reason])
      redirect_to admin_user_path(@user), notice: 'Warning has been issued to the user.'
    else
      redirect_to admin_user_path(@user), alert: 'Failed to issue warning.'
    end
  end

  def verify_seller
    if UserManagementService.new(@user, current_user).verify_seller
      redirect_to admin_user_path(@user), notice: 'Seller has been verified.'
    else
      redirect_to admin_user_path(@user), alert: 'Failed to verify seller.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
