class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items

  enum status: {
    pending: 0,
    processing: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4,
    refunded: 5
  }

  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_address, presence: true
  validates :status, presence: true

  before_validation :set_default_status, on: :create
  after_create :process_order
  after_create :award_points

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
    user.increment!(:points, points)
    
    # Award points to sellers
    order_items.each do |order_item|
      seller = order_item.item.user
      seller_points = (order_item.unit_price * order_item.quantity * 15).to_i # 15 points per dollar for sellers
      seller.increment!(:points, seller_points)
    end
  end
end
