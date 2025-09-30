class Dispute < ApplicationRecord
  belongs_to :order
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :moderator, class_name: 'User', optional: true
  belongs_to :escrow_transaction, optional: true
  
  has_many :comments, class_name: 'DisputeComment', dependent: :destroy
  has_many :evidences, class_name: 'DisputeEvidence', dependent: :destroy
  has_one :resolution, class_name: 'DisputeResolution', dependent: :destroy

  enum status: {
    pending: 0,
    under_review: 1,
    resolved: 2,
    dismissed: 3,
    refunded: 4,
    partially_refunded: 5
  }

  enum dispute_type: {
    non_delivery: 0,
    quality_issues: 1,
    not_as_described: 2,
    damaged_in_transit: 3,
    other: 4
  }

  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20, maximum: 1000 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :dispute_type, presence: true
  
  scope :unassigned, -> { where(moderator: nil) }
  scope :active, -> { where.not(status: [:resolved, :dismissed, :refunded, :partially_refunded]) }
  scope :needs_review, -> { where(status: :under_review) }
  scope :pending_resolution, -> { where(status: [:pending, :under_review]) }
  
  after_create :freeze_escrow_transaction
  after_create :notify_parties
  after_update :notify_status_change, if: :saved_change_to_status?

  def assign_to_moderator(moderator)
    return false unless moderator.can_moderate_disputes?

    transaction do
      update(
        moderator: moderator,
        status: :under_review,
        moderator_assigned_at: Time.current
      )
      
      notify_parties_of_moderator_assignment
      create_activity(:moderator_assigned)
    end
  end

  def resolve(resolution_params)
    return false unless can_be_resolved?

    transaction do
      resolution = build_resolution(resolution_params)
      
      if resolution.save
        process_resolution(resolution)
        update(status: resolution.resolution_type, resolved_at: Time.current)
        create_activity(:resolved)
        notify_resolution
        true
      else
        errors.add(:base, "Failed to save resolution: #{resolution.errors.full_messages.join(', ')}")
        false
      end
    end
  end

  def add_evidence(user, evidence_params)
    return false unless can_participate?(user)

    evidence = evidences.create(
      user: user,
      title: evidence_params[:title],
      description: evidence_params[:description],
      attachment: evidence_params[:attachment]
    )

    if evidence.persisted?
      create_activity(:evidence_added, user: user)
      notify_evidence_added(evidence)
      true
    else
      false
    end
  end

  def can_participate?(user)
    [buyer_id, seller_id, moderator_id].include?(user.id)
  end

  private

  def can_be_resolved?
    moderator.present? && !resolved? && !dismissed? && !refunded?
  end

  def process_resolution(resolution)
    case resolution.resolution_type
    when 'refunded'
      escrow_transaction.refund(resolution.refund_amount, admin_approved: true)
    when 'partially_refunded'
      escrow_transaction.refund(resolution.refund_amount, admin_approved: true)
    when 'resolved'
      escrow_transaction.release_funds(admin_approved: true)
    end
  end

  def freeze_escrow_transaction
    escrow_transaction&.update(status: :disputed)
  end

  def notify_parties
    [buyer, seller].each do |user|
      NotificationService.notify(
        user: user,
        title: "Dispute Opened",
        message: "A dispute has been opened for order ##{order.id}",
        resource: self
      )
    end
  end

  def notify_status_change
    [buyer, seller, moderator].compact.each do |user|
      NotificationService.notify(
        user: user,
        title: "Dispute Status Updated",
        message: "Dispute status changed to: #{status}",
        resource: self
      )
    end
  end

  def notify_parties_of_moderator_assignment
    [buyer, seller].each do |user|
      NotificationService.notify(
        user: user,
        title: "Moderator Assigned",
        message: "A moderator has been assigned to your dispute",
        resource: self
      )
    end
  end

  def notify_resolution
    [buyer, seller].each do |user|
      NotificationService.notify(
        user: user,
        title: "Dispute Resolved",
        message: "Your dispute has been resolved. Resolution: #{resolution.notes}",
        resource: self
      )
    end
  end

  def notify_evidence_added(evidence)
    [buyer, seller, moderator].compact.each do |user|
      next if user.id == evidence.user_id
      
      NotificationService.notify(
        user: user,
        title: "New Evidence Added",
        message: "New evidence has been added to the dispute",
        resource: evidence
      )
    end
  end

  def create_activity(action, user: nil)
    DisputeActivity.create!(
      dispute: self,
      user: user || moderator,
      action: action,
      data: {
        status: status,
        resolution_type: resolution&.resolution_type,
        refund_amount: resolution&.refund_amount
      }
    )
  end
end
