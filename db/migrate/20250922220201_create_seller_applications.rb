class CreateSellerApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :seller_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.text :note
      t.text :rejection_reason
      t.references :reviewed_by, null: true, foreign_key: { to_table: :users }
      t.datetime :reviewed_at

      t.timestamps
    end
  end
end
