class AddSellerToOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :orders, :seller, null: false, foreign_key: { to_table: :users }
  end
end
