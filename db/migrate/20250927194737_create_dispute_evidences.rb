class CreateDisputeEvidences < ActiveRecord::Migration[8.0]
  def change
    create_table :dispute_evidences do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :dispute, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :dispute_evidences, [:dispute_id, :created_at]
  end
end
