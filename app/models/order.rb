class Order < ApplicationRecord
  belongs_to :buyer, class_name: 'User', foreign_key: 'user_id'
  belongs_to :seller, class_name: 'User'
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  has_one :escrow_transaction, dependent: :restrict_with_error
  has_one :review_invitation, dependent: :destroy
  has_one :review, through: :review_invitation
  has_one :dispute

  enum status: {
    pending: 0,
    processing: 1,
    shipped: 2,
    delivered: 3,
    completed: 4,
    cancelled: 5,
    refunded: 6
  }

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :shipping_address, presence: true
  validates :status, presence: true

  before_validation :set_default_status, on: :create
  after_create :process_order
  after_create :award_points
  after_create :create_escrow_transaction
  after_update :check_delivery_confirmation, if: :saved_change_to_status?

  scope :pending_finalization, -> { 
    where(status: :delivered)
      .where('delivery_confirmed_at <= ?', 7.days.ago)
      .where(finalized_at: nil)
      .joins(:escrow_transaction)
      .where.not(escrow_transactions: { status: :disputed })
  }

  scope :recent, -> { order(created_at: :desc) }
  scope :unfinalized, -> { where(finalized_at: nil) }
  scope :finalized, -> { where.not(finalized_at: nil) }

  def total_items
    order_items.sum(:quantity)
  end

  def calculate_total
    order_items.sum { |item| item.unit_price * item.quantity }
  end

  private

  def set_default_status
    self.status ||= :pending
  end

  def process_order
    # Mark items as sold
    items.each do |item|
      item.update(status: :sold)
    end

    # Clear the user's cart
    user.clear_cart
  end

  def award_points
    # Award points to both buyer and sellers
    points = (total_amount * 10).to_i # 10 points per dollar
    
    # Award points to buyer
    buyer.increment!(:points, points)
    
    # Award points to seller
    seller_points = (total_amount * 15).to_i # 15 points per dollar for sellers
    seller.increment!(:points, seller_points)
  end

  def confirmed_delivery?
    delivered? && delivery_confirmed_at.present?
  end

  def finalized?
    finalized_at.present?
  end

  def disputed?
    escrow_transaction&.disputed?
  end

  def review_pending?
    review_invitation&.pending?
  end

  def can_be_finalized?
    OrderFinalizationService.new(self).send(:can_finalize?)
  end

  def finalize(admin_approved: false)
    OrderFinalizationService.new(self).finalize(admin_approved: admin_approved)
  end

  private

  def create_escrow_transaction
    EscrowTransaction.create!(
      order: self,
      buyer: buyer,
      seller: seller,
      amount: total_amount
    )
  end

  def check_delivery_confirmation
    if saved_change_to_status? && status == 'delivered'
      update_column(:delivery_confirmed_at, Time.current)
      schedule_auto_finalization
    end
  end

  def schedule_auto_finalization
    CheckOrderFinalizationsJob.schedule
  end
end
