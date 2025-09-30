class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :sender, foreign_key: { to_table: :users }
      t.references :recipient, foreign_key: { to_table: :users }
      t.references :order, null: true, foreign_key: true

      t.timestamps
    end

    add_index :conversations, [:sender_id, :recipient_id], unique: true
  end
end
