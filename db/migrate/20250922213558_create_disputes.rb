class CreateDisputes < ActiveRecord::Migration[8.0]
  def change
    create_table :disputes do |t|
      t.string :title
      t.text :description
      t.integer :status
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :reported_user, null: false, foreign_key: { to_table: :users }
      t.references :moderator, null: true, foreign_key: { to_table: :users }
      t.text :resolution_notes

      t.timestamps
    end
  end
end
