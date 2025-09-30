class AddFeeTypeToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :fee_type, :string, default: 'default'
    add_index :categories, :fee_type
  end
end