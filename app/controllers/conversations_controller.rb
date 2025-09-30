class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show, :archive, :unarchive]

  def index
    @conversations = current_user.conversations
                               .includes(:sender, :recipient)
                               .order(last_message_at: :desc)
    
    @active_conversations = @conversations.active
    @archived_conversations = @conversations.archived
  end

  def show
    @conversations = current_user.conversations
                               .active
                               .includes(:sender, :recipient)
                               .order(last_message_at: :desc)
    
    @conversation.mark_as_read!(current_user) if @conversation
  end

  def create
    if Conversation.between(params[:sender_id], params[:recipient_id]).present?
      @conversation = Conversation.between(params[:sender_id], params[:recipient_id]).first
    else
      @conversation = Conversation.create!(conversation_params)
    end
    
    redirect_to @conversation
  end

  def archive
    @conversation.archive!
    redirect_to conversations_path, notice: 'Conversation archived'
  end

  def unarchive
    @conversation.unarchive!
    redirect_to @conversation, notice: 'Conversation restored'
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end
end
