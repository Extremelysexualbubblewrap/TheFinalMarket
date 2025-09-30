class AddOrderAndInvitationToReviews < ActiveRecord::Migration[8.0]
  def change
    add_reference :reviews, :review_invitation, null: true, foreign_key: true
    add_reference :reviews, :order, null: true, foreign_key: true
    add_column :reviews, :pros, :text
    add_column :reviews, :cons, :text
  end
end
