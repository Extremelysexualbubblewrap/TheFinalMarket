class AddSellerTierAndStats < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :seller_tier, :string, default: 'standard'
    add_column :users, :total_sales_cents, :bigint, default: 0
    add_column :users, :monthly_sales_cents, :bigint, default: 0
    add_column :users, :last_sales_update, :datetime
    
    add_index :users, :seller_tier
    add_index :users, :monthly_sales_cents
  end
end