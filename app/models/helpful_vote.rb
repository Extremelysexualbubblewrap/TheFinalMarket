class HelpfulVote < ApplicationRecord
  belongs_to :user
  belongs_to :review

  validates :user_id, uniqueness: { scope: :review_id }
  validate :cannot_vote_on_own_review
  
  private

  def cannot_vote_on_own_review
    if user_id == review.reviewer_id
      errors.add(:base, "You cannot mark your own review as helpful")
    end
  end
end