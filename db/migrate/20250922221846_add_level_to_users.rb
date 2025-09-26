class AddLevelToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :level, :integer, default: 1, null: false
  end
end
