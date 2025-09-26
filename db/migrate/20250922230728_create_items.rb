class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :status, default: 0, null: false
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :condition, null: false
      t.integer :view_count, default: 0, null: false

      t.timestamps
    end

    add_index :items, :name
    add_index :items, :status
    add_index :items, :price
    add_index :items, :condition
  end
end
