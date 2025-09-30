class CreateReviewInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :review_invitations do |t|
      t.references :order, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :seller, null: false, foreign_key: { to_table: :users }
      t.datetime :expires_at, null: false
      t.datetime :completed_at
      t.string :token, null: false

      t.timestamps
    end

    add_index :review_invitations, :token, unique: true
    add_index :review_invitations, :expires_at
  end
end
