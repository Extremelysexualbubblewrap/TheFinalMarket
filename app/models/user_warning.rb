class UserWarning < ApplicationRecord
  belongs_to :user
  belongs_to :moderator, class_name: 'User'

  enum level: { minor: 0, moderate: 1, severe: 2 }

  validates :reason, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :level, presence: true
  validate :moderator_has_permission

  after_create :notify_user
  after_create :check_for_automatic_suspension

  scope :active, -> { where('expires_at > ? OR expires_at IS NULL', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def active?
    expires_at.nil? || expires_at > Time.current
  end

  private

  def moderator_has_permission
    unless moderator.moderator? || moderator.admin?
      errors.add(:moderator, "must be a moderator or admin")
    end
  end

  def notify_user
    user.notify(
      actor: moderator,
      action: 'issued_warning',
      notifiable: self
    )
  end

  def check_for_automatic_suspension
    active_warnings_count = user.warnings.active.count
    
    if active_warnings_count >= 3
      # Create a suspension record (to be implemented)
      user.update(suspended_until: 7.days.from_now)
      user.notify(
        actor: moderator,
        action: 'account_suspended',
        notifiable: self
      )
    end
  end
end
