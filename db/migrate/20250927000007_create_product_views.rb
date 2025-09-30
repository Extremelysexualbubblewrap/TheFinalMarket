class CreateProductViews < ActiveRecord::Migration[7.1]
  def change
    create_table :product_views do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :view_count, default: 1
      t.datetime :last_viewed_at

      t.timestamps
    end

    add_index :product_views, [:user_id, :product_id], unique: true
    add_index :product_views, :last_viewed_at
  end
end