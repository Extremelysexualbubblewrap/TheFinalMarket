class AdminTransaction < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  belongs_to :approvable, polymorphic: true
  
  validates :action, presence: true
  validates :reason, presence: true, length: { minimum: 10, maximum: 1000 }
  
  before_validation :ensure_admin_permissions
  after_create :log_action
  
  enum action: {
    escrow_release: 0,
    escrow_refund: 1,
    dispute_resolution: 2,
    order_finalization: 3,
    account_suspension: 4,
    other: 5
  }
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_admin, ->(admin) { where(admin: admin) }
  scope :by_action, ->(action) { where(action: action) }
  
  private
  
  def ensure_admin_permissions
    unless admin&.admin?
      errors.add(:admin, "must have admin permissions")
      throw(:abort)
    end
  end
  
  def log_action
    AdminActivityLog.create!(
      admin: admin,
      action: action,
      resource: approvable,
      details: {
        reason: reason,
        approved_at: created_at
      }
    )
  end
end