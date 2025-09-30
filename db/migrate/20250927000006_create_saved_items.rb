class CreateSavedItems < ActiveRecord::Migration[7.1]
  def change
    create_table :saved_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.references :variant, foreign_key: true
      t.text :note
      
      t.timestamps
    end

    add_index :saved_items, [:user_id, :product_id, :variant_id], unique: true
  end
end