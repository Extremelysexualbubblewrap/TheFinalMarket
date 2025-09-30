class EscrowHold < ApplicationRecord
  belongs_to :payment_account
  belongs_to :order, optional: true

  monetize :amount_cents

  enum status: {
    active: 'active',
    released: 'released',
    expired: 'expired'
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :reason, presence: true
  validates :status, presence: true

  before_create :set_expiry
  after_create :schedule_expiry_check

  scope :expiring, -> { active.where('expires_at <= ?', 24.hours.from_now) }

  def release!
    return false unless active?

    transaction do
      update!(status: :released, released_at: Time.current)
      payment_account.release_funds(amount, reason)
    end
    true
  end

  def expire!
    return false unless active?
    return false unless expires_at <= Time.current

    transaction do
      update!(status: :expired)
      payment_account.release_funds(amount, "Expired: #{reason}")
    end
    true
  end

  private

  def set_expiry
    self.expires_at ||= case reason
    when /bond/i
      30.days.from_now
    else
      7.days.from_now
    end
  end

  def schedule_expiry_check
    CheckEscrowExpiryJob.set(wait_until: expires_at).perform_later(self)
  end
end
