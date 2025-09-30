class PushNotificationService
  def initialize
    @vapid_private_key = Rails.application.credentials.vapid_private_key
    @vapid_public_key = Rails.application.credentials.vapid_public_key
    @web_push = WebPush
  end

  def send_notification(subscription, title:, body:, url: nil, actions: nil)
    payload = {
      title: title,
      body: body,
      url: url || Rails.application.routes.url_helpers.root_url,
      actions: actions
    }

    @web_push.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        subject: "mailto:#{Rails.application.credentials.push_notification_email}",
        public_key: @vapid_public_key,
        private_key: @vapid_private_key
      }
    )
  end

  def self.notify_user(user, title:, body:, url: nil, actions: nil)
    user.push_subscriptions.each do |subscription|
      new.send_notification(
        subscription,
        title: title,
        body: body,
        url: url,
        actions: actions
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      subscription.destroy
    end
  end

  def self.notify_all(title:, body:, url: nil, actions: nil)
    PushSubscription.find_each do |subscription|
      new.send_notification(
        subscription,
        title: title,
        body: body,
        url: url,
        actions: actions
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      subscription.destroy
    end
  end
end