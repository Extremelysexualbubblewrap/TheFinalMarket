class MessageNotification < Noticed::Base
  deliver_by :database
  deliver_by :action_cable, channel: "NotificationChannel"

  param :message

  def message
    params[:message]
  end

  def url
    conversation_path(message.conversation)
  end

  def message_preview
    message.preview_text.truncate(50)
  end

  def title
    "New message from #{message.user.name}"
  end

  def body
    message_preview
  end
end