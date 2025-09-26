class SellerApplication < ApplicationRecord
  belongs_to :user
  belongs_to :reviewed_by, class_name: 'User', optional: true

  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected'
  }

  validates :note, presence: true, length: { minimum: 50, maximum: 2000 }
  validates :user_id, uniqueness: { message: "already has a pending or approved application" }
  validate :user_is_not_already_a_seller

  after_create :update_user_status
  after_update :handle_application_decision

  private

  def user_is_not_already_a_seller
    if user.gem?
      errors.add(:user, "is already a Gem (seller)")
    end
  end

  def update_user_status
    user.update(seller_status: 'pending_approval')
  end

  def handle_application_decision
    if saved_change_to_status?
      case status
      when 'approved'
        user.update(seller_status: 'pending_bond')
        user.notify(actor: reviewed_by, action: 'seller_application_approved', notifiable: self)
      when 'rejected'
        user.update(seller_status: 'rejected', seller_rejection_reason: rejection_reason)
        user.notify(actor: reviewed_by, action: 'seller_application_rejected', notifiable: self)
      end
    end
  end
end
