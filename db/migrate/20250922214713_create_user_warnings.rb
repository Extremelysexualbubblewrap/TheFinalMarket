class CreateUserWarnings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_warnings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :moderator, null: false, foreign_key: { to_table: :users }
      t.text :reason
      t.integer :level
      t.datetime :expires_at

      t.timestamps
    end
  end
end
