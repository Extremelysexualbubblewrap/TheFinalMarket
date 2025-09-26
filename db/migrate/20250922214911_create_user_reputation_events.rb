class CreateUserReputationEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :user_reputation_events do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :points
      t.string :reason

      t.timestamps
    end
  end
end
