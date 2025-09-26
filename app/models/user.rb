class User < ApplicationRecord
  include UserReputation
  include UserLeveling

  has_secure_password

  enum role: { user: 0, moderator: 1, admin: 2 }
  enum user_type: { seeker: 'seeker', gem: 'gem' }
  enum seller_status: {
    not_applied: 'not_applied',
    pending_approval: 'pending_approval',
    pending_bond: 'pending_bond',
    approved: 'approved',
    rejected: 'rejected',
    suspended: 'suspended'
  }

  after_initialize :set_default_user_type_and_status, if: :new_record?

  attribute :suspended_until, :datetime

  has_one :seller_application, dependent: :destroy

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                   format: { with: URI::MailTo::EMAIL_REGEXP },
                   uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }

  before_save { self.email = email.downcase }
  
  has_one :cart, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :reviewed_products, through: :reviews, source: :product
  
  # Dispute associations
  has_many :reported_disputes, class_name: 'Dispute', foreign_key: 'reporter_id', dependent: :destroy
  has_many :disputes_against, class_name: 'Dispute', foreign_key: 'reported_user_id'
  has_many :moderated_disputes, class_name: 'Dispute', foreign_key: 'moderator_id'

  # Notifications
  has_many :notifications, as: :recipient, dependent: :destroy
  
  # User warnings
  has_many :warnings, class_name: 'UserWarning', dependent: :destroy
  
  # Cart related
  has_many :cart_items, dependent: :destroy
  has_many :cart_items_count, -> { select('item_id, COUNT(*) as count').group('item_id') }, class_name: 'CartItem'
  
  def notify(actor:, action:, notifiable:)
    notifications.create!(
      actor: actor,
      action: action,
      notifiable: notifiable
    )
  end

  def gem?
    user_type == 'gem'
  end

  def seeker?
    user_type == 'seeker'
  end

  def can_sell?
    gem? && seller_status == 'approved'
  end

  private

  def set_default_role
    self.role ||= :user
  end

  def set_default_user_type_and_status
    self.user_type ||= 'seeker'
    self.seller_status ||= 'not_applied'
    self.level ||= 1
  end

  def level_up!
    return if level >= 6
    update(level: level + 1)
  end

  # Cart methods
  def add_to_cart(item, quantity = 1)
    cart_items.find_or_initialize_by(item: item).tap do |cart_item|
      cart_item.quantity = cart_item.new_record? ? quantity : cart_item.quantity + quantity
      cart_item.save
    end
  end

  def remove_from_cart(item, quantity = nil)
    cart_item = cart_items.find_by(item: item)
    return unless cart_item

    if quantity.nil? || cart_item.quantity <= quantity
      cart_item.destroy
    else
      cart_item.update(quantity: cart_item.quantity - quantity)
    end
  end

  def cart_total
    cart_items.sum(&:subtotal)
  end

  def clear_cart
    cart_items.destroy_all
  end

  def level_name
    case level
    when 1 then "Garnet"
    when 2 then "Topaz"
    when 3 then "Emerald"
    when 4 then "Sapphire"
    when 5 then "Ruby"
    when 6 then "Diamond"
    end
  end
end
