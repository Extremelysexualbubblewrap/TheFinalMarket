class ReviewInvitation < ApplicationRecord
  belongs_to :order
  belongs_to :user
  belongs_to :item
  has_one :review, dependent: :nullify

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :status, presence: true

  enum status: {
    pending: 'pending',
    completed: 'completed',
    expired: 'expired'
  }

  # Scopes
  scope :active, -> { pending.where('expires_at > ?', Time.current) }
  scope :pending, -> { where(status: :pending) }
  scope :completed, -> { where(status: :completed) }
  scope :expired, -> { where(status: :expired) }

  before_validation :set_defaults, on: :create
  after_create :send_invitation_email
  
  def expire!
    return unless pending?
    
    transaction do
      update!(status: :expired)
      NotificationService.notify(
        recipient: user,
        action: :review_expired,
        notifiable: order
      )
    end
  end

  def complete!
    return unless pending?
    update!(status: :completed)
  end

  private

  def set_defaults
    self.token = generate_unique_token
    self.expires_at ||= 30.days.from_now
    self.status ||= :pending
  end

  def generate_unique_token
    loop do
      token = SecureRandom.urlsafe_base64(32)
      break token unless self.class.exists?(token: token)
    end
  end

  def send_invitation_email
    ReviewMailer.with(review_invitation: self).invitation_email.deliver_later
  end
end