class AddBondStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :bond_status, :string, default: 'none'
    add_index :users, :bond_status
  end
end
