class Dispute < ApplicationRecord
  belongs_to :reporter, class_name: 'User'
  belongs_to :reported_user, class_name: 'User'
  belongs_to :moderator, class_name: 'User', optional: true
  
  has_many :comments, class_name: 'DisputeComment', dependent: :destroy

  enum status: {
    pending: 0,
    under_review: 1,
    resolved: 2,
    dismissed: 3
  }

  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20, maximum: 1000 }
  
  scope :unassigned, -> { where(moderator: nil) }
  scope :active, -> { where.not(status: [:resolved, :dismissed]) }
  
  def assign_to_moderator(moderator)
    if moderator.moderator? || moderator.admin?
      update(moderator: moderator, status: :under_review)
    else
      errors.add(:moderator, "must be a moderator or admin")
      false
    end
  end

  def resolve(resolution_notes)
    if resolution_notes.present?
      update(resolution_notes: resolution_notes, status: :resolved)
    else
      errors.add(:resolution_notes, "can't be blank when resolving a dispute")
      false
    end
  end

  def dismiss(resolution_notes)
    if resolution_notes.present?
      update(resolution_notes: resolution_notes, status: :dismissed)
    else
      errors.add(:resolution_notes, "can't be blank when dismissing a dispute")
      false
    end
  end
end
