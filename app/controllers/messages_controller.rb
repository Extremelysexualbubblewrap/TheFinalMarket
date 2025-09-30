class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :ensure_participant

  def create
    @message = @conversation.messages.new(message_params)
    @message.user = current_user
    @message.message_type = determine_message_type
    @message.status = 'sent'

    if @message.save
      process_attachments if params[:message][:files].present?
      notify_recipient
      render_turbo_stream
    else
      render turbo_stream: turbo_stream.replace(
        'message_form',
        partial: 'messages/form',
        locals: { message: @message }
      )
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def ensure_participant
    unless [@conversation.sender_id, @conversation.recipient_id].include?(current_user.id)
      redirect_to conversations_path, alert: "You don't have access to this conversation"
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end

  def determine_message_type
    return 'system' if params[:message][:system] == 'true'
    if params[:message][:files].present?
      file = params[:message][:files].first
      return file.content_type.start_with?('image/') ? 'image' : 'file'
    end
    'text'
  end

  def process_attachments
    @message.files.attach(params[:message][:files])
  end

  def notify_recipient
    recipient = @conversation.other_participant(current_user)
    MessageNotification.with(message: @message).deliver_later(recipient)
  end

  def render_turbo_stream
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.append('messages', partial: 'messages/message', locals: { message: @message }),
          turbo_stream.replace('message_form', partial: 'messages/form', locals: { message: @conversation.messages.new })
        ]
      end
    end
  end
end
