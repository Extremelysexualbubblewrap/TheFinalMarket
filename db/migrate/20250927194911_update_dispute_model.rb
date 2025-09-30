class UpdateDisputeModel < ActiveRecord::Migration[8.0]
  def change
    # Remove old columns
    remove_reference :disputes, :reporter
    remove_reference :disputes, :reported_user
    
    # Add new columns and references
    add_reference :disputes, :order, null: false, foreign_key: true
    add_reference :disputes, :buyer, null: false, foreign_key: { to_table: :users }
    add_reference :disputes, :seller, null: false, foreign_key: { to_table: :users }
    add_reference :disputes, :escrow_transaction, foreign_key: true
    
    add_column :disputes, :amount, :decimal, precision: 10, scale: 2, null: false
    add_column :disputes, :dispute_type, :integer, null: false
    add_column :disputes, :moderator_assigned_at, :datetime
    add_column :disputes, :resolved_at, :datetime
    
    # Add new indexes
    add_index :disputes, :dispute_type
    add_index :disputes, :status
    add_index :disputes, [:buyer_id, :created_at]
    add_index :disputes, [:seller_id, :created_at]
    add_index :disputes, :resolved_at
  end
end
