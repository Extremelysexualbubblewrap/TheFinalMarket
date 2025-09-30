# app/jobs/check_escrow_expiry_job.rb
class CheckEscrowExpiryJob < ApplicationJob
  queue_as :default

  def perform(escrow_hold)
    return unless escrow_hold.active?
    return unless escrow_hold.expires_at <= Time.current

    if escrow_hold.expire!
      NotificationService.notify(
        recipient: escrow_hold.payment_account.user,
        action: :escrow_expired,
        notifiable: escrow_hold.order
      )
    end
  end
end