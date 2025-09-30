class Conversation < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  belongs_to :order, optional: true
  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  validates :sender_id, uniqueness: { scope: :recipient_id }

  scope :between, -> (sender_id, recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id =?) OR (conversations.sender_id = ? AND conversations.recipient_id =?)", 
          sender_id, recipient_id, recipient_id, sender_id)
  end

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
  scope :with_unread_messages, -> { where('unread_count > 0') }
  
  def other_participant(current_user)
    current_user == sender ? recipient : sender
  end

  def subscribed(user)
    broadcast_user_status(user, true)
    mark_messages_as_delivered(user)
  end

  def unsubscribed(user)
    broadcast_user_status(user, false)
  end

  def broadcast_typing(user)
    broadcast_replace_to self,
                        target: "user_#{user.id}_typing",
                        partial: "conversations/typing",
                        locals: { user: user }
  end

  def broadcast_stop_typing(user)
    broadcast_remove_to self,
                       target: "user_#{user.id}_typing"
  end

  def broadcast_user_status(user, online)
    broadcast_replace_to self,
                        target: "user_#{user.id}_status",
                        partial: "conversations/status",
                        locals: { user: user, online: online }
  end

  def mark_messages_as_delivered(user)
    messages.sent.where.not(user: user).each(&:mark_as_delivered!)
  end

  def mark_as_read!(by_user)
    if by_user == recipient
      update(unread_count: 0)
      messages.where.not(user: by_user).each { |msg| msg.mark_as_read!(by_user) }
    end
  end

  def archive!
    update!(archived: true)
  end

  def unarchive!
    update!(archived: false)
  end
end
