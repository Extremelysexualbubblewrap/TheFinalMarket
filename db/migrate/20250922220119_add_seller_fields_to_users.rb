class AddSellerFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :user_type, :string, default: 'seeker'
    add_column :users, :seller_status, :string, default: nil
    add_column :users, :seller_approved_at, :datetime
    add_column :users, :seller_bond_paid_at, :datetime
    add_column :users, :seller_bond_amount, :decimal, precision: 10, scale: 2
    add_column :users, :seller_application_date, :datetime
    add_column :users, :seller_application_note, :text
    add_column :users, :seller_rejection_reason, :text
    add_column :users, :seller_bond_refunded_at, :datetime
    
    add_index :users, :user_type
    add_index :users, :seller_status
  end
end
