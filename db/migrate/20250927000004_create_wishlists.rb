class CreateWishlists < ActiveRecord::Migration[7.1]
  def change
    create_table :wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :wishlist_items_count, default: 0, null: false
      t.timestamps
    end

    create_table :wishlist_items do |t|
      t.references :wishlist, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end

    add_index :wishlist_items, [:wishlist_id, :product_id], unique: true
  end
end