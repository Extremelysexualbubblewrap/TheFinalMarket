class OrderFinalizationService
  FINALIZATION_PERIOD = 7.days
  REMINDER_BEFORE_AUTO = 24.hours

  def initialize(order)
    @order = order
    @escrow_transaction = order.escrow_transaction
  end

  def self.check_pending_finalizations
    Order.pending_finalization.find_each do |order|
      new(order).process_finalization
    end
  end

  def process_finalization
    return unless should_process?

    if should_auto_finalize?
      auto_finalize
    elsif should_send_reminder?
      send_finalization_reminder
    end
  end

  def finalize(admin_approved: false)
    return false unless can_finalize?

    ApplicationRecord.transaction do
      @order.update!(status: :completed, finalized_at: Time.current)
      @escrow_transaction.release_funds(admin_approved: admin_approved)
      create_review_invitation
      notify_parties(:order_finalized)
      true
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to finalize order #{@order.id}: #{e.message}")
    false
  end

  private

  def should_process?
    @order.confirmed_delivery? && !@order.finalized? && !@order.disputed?
  end

  def should_auto_finalize?
    @order.delivery_confirmed_at <= FINALIZATION_PERIOD.ago
  end

  def should_send_reminder?
    time_until_auto = time_until_auto_finalization
    time_until_auto.positive? && time_until_auto <= REMINDER_BEFORE_AUTO
  end

  def can_finalize?
    should_process? && 
      !@order.review_pending? &&
      !@escrow_transaction.disputed?
  end

  def auto_finalize
    if finalize(admin_approved: true)
      Rails.logger.info("Auto-finalized order #{@order.id}")
      notify_parties(:order_auto_finalized)
    end
  end

  def time_until_auto_finalization
    (@order.delivery_confirmed_at + FINALIZATION_PERIOD) - Time.current
  end

  def create_review_invitation
    ReviewInvitation.create!(
      order: @order,
      buyer: @order.buyer,
      seller: @order.seller,
      expires_at: 30.days.from_now
    )
  end

  def notify_parties(event)
    [@order.buyer, @order.seller].each do |user|
      NotificationService.notify(
        user: user,
        title: notification_title(event),
        message: notification_message(event),
        resource: @order
      )
    end
  end

  def send_finalization_reminder
    NotificationService.notify(
      user: @order.buyer,
      title: "Action Required: Order Finalization",
      message: "Your order ##{@order.id} will be automatically finalized in #{time_until_auto_finalization.round} hours. Please review the order and take any necessary actions.",
      resource: @order
    )
  end

  def notification_title(event)
    case event
    when :order_finalized
      "Order Finalized"
    when :order_auto_finalized
      "Order Auto-Finalized"
    end
  end

  def notification_message(event)
    case event
    when :order_finalized
      "Order ##{@order.id} has been finalized. The funds have been released to the seller."
    when :order_auto_finalized
      "Order ##{@order.id} has been automatically finalized after #{FINALIZATION_PERIOD.in_days} days. The funds have been released to the seller."
    end
  end
end