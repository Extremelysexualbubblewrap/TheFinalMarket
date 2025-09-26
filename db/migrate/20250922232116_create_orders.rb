class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0
      t.string :tracking_number
      t.text :shipping_address, null: false
      t.text :notes

      t.timestamps
    end

    add_index :orders, :status
    add_index :orders, :tracking_number
    add_index :orders, :created_at
  end
end
