class AddEnhancementsToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :archived, :boolean
    add_column :conversations, :last_message, :text
    add_column :conversations, :unread_count, :integer
    add_column :conversations, :last_message_at, :datetime
  end
end
