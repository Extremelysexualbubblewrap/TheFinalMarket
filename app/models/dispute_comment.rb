class DisputeComment < ApplicationRecord
  belongs_to :user
  belongs_to :dispute

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }

  after_create_commit :broadcast_to_dispute

  private

  def broadcast_to_dispute
    broadcast_append_to "dispute_#{dispute.id}_comments",
      partial: "dispute_comments/comment",
      locals: { comment: self }
  end
end
