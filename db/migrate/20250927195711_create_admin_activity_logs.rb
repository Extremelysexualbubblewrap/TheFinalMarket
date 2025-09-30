 class CreateAdminActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_activity_logs do |t|
      t.string :action
      t.json :details
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.references :resource, polymorphic: true, null: false

      t.timestamps
    end
  end
end
