class CreateDisputeComments < ActiveRecord::Migration[8.0]
  def change
    create_table :dispute_comments do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :dispute, null: false, foreign_key: true

      t.timestamps
    end
  end
end
