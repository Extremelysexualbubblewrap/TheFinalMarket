class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stream_for conversation
    conversation.subscribed(current_user)
  end

  def unsubscribed
    conversation.unsubscribed(current_user)
  end

  def typing(data)
    conversation.broadcast_typing(current_user)
  end

  def stop_typing(data)
    conversation.broadcast_stop_typing(current_user)
  end

  def mark_as_read(data)
    message = conversation.messages.find(data['message_id'])
    message.mark_as_read!(current_user)
  end

  def mark_as_delivered(data)
    message = conversation.messages.find(data['message_id'])
    message.mark_as_delivered!
  end

  private

  def conversation
    @conversation ||= Conversation.find(params[:id])
  end
end
