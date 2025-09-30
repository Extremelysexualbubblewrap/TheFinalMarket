class CreateDisputeActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :dispute_activities do |t|
      t.string :action, null: false
      t.json :data, null: false
      t.references :dispute, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :dispute_activities, [:dispute_id, :created_at]
    add_index :dispute_activities, :action
  end
end
