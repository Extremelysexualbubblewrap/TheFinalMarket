class CreateAdminTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_transactions do |t|
      t.integer :action
      t.text :reason
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.references :approvable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
