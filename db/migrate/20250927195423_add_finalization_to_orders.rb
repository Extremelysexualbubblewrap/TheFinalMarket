class AddFinalizationToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :delivery_confirmed_at, :datetime
    add_column :orders, :finalized_at, :datetime
    add_column :orders, :auto_finalize_at, :datetime

    add_index :orders, :delivery_confirmed_at
    add_index :orders, :finalized_at
    add_index :orders, :auto_finalize_at
  end
end
