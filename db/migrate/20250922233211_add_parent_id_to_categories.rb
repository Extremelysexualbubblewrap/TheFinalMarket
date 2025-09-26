class AddParentIdToCategories < ActiveRecord::Migration[8.0]
  def change
    add_reference :categories, :parent, null: true, foreign_key: { to_table: :categories }
    add_index :categories, [:parent_id, :name], unique: true
  end
end
