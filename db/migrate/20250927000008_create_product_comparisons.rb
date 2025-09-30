class CreateProductComparisons < ActiveRecord::Migration[7.1]
  def change
    create_table :compare_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end

    create_table :compare_items do |t|
      t.references :compare_list, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end

    add_index :compare_items, [:compare_list_id, :product_id], unique: true
  end
end