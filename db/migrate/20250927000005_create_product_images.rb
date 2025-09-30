class CreateProductImages < ActiveRecord::Migration[7.1]
  def change
    create_table :product_images do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :position, null: false
      t.boolean :is_primary, default: false
      t.string :alt_text
      t.timestamps
    end

    add_index :product_images, [:product_id, :position]
    add_index :product_images, [:product_id, :is_primary]
  end
end