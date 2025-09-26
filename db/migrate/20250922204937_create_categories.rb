class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.references :parent, foreign_key: { to_table: :categories }
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :categories, [:parent_id, :name], unique: true
    add_index :categories, :active
    add_index :categories, :position
  end
end
