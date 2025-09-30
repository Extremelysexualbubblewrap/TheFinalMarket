class DisputeActivity < ApplicationRecord
  belongs_to :dispute
  belongs_to :user
  
  serialize :data, JSON

  validates :action, presence: true
  validates :data, presence: true

  scope :chronological, -> { order(created_at: :asc) }
  scope :recent_first, -> { order(created_at: :desc) }

  def self.action_types
    %w[
      opened
      moderator_assigned
      evidence_added
      comment_added
      resolved
      refunded
      partially_refunded
      dismissed
    ]
  end

  validates :action, inclusion: { in: action_types }
end