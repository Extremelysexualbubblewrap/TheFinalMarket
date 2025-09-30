class UserManagementService
  def initialize(user, admin_user)
    @user = user
    @admin_user = admin_user
  end

  def suspend(reason)
    return false if reason.blank?

    @user.update(suspended: true, suspension_reason: reason)
    NotificationService.notify(
      user: @user,
      title: "Account Suspended",
      body: "Your account has been suspended. Reason: #{reason}",
      category: :account_warning
    )
    true
  end

  def warn(reason)
    return false if reason.blank?

    @user.user_warnings.create(reason: reason, admin: @admin_user)
    NotificationService.notify(
      user: @user,
      title: "Account Warning",
      body: "You have received a warning. Reason: #{reason}",
      category: :account_warning
    )
    true
  end

  def verify_seller
    return false unless @user.seller?

    @user.update(seller_verified: true)
    NotificationService.notify(
      user: @user,
      title: "Seller Account Verified",
      body: "Congratulations! Your seller account has been verified.",
      category: :account_update
    )
    true
  end
end
