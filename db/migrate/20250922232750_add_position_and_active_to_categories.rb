class AddPositionAndActiveToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :position, :integer, default: 0, null: false
    add_column :categories, :active, :boolean, default: true, null: false
    
    add_index :categories, :position
    add_index :categories, :active
  end
end
