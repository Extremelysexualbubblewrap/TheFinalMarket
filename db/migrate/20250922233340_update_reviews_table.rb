class UpdateReviewsTable < ActiveRecord::Migration[8.0]
  def change
    # Remove old columns
    remove_reference :reviews, :product, foreign_key: true
    rename_column :reviews, :comment, :content

    # Add new columns
    add_reference :reviews, :reviewable, polymorphic: true, null: false
    add_column :reviews, :helpful_count, :integer, default: 0, null: false
    rename_column :reviews, :user_id, :reviewer_id

    # Create helpful votes table
    create_table :helpful_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :review, null: false, foreign_key: true

      t.timestamps
    end

    add_index :helpful_votes, [:user_id, :review_id], unique: true
    add_index :reviews, [:reviewer_id, :reviewable_type, :reviewable_id], unique: true, name: 'idx_reviews_on_reviewer_and_reviewable'
  end
end
