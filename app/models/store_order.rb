# app/models/store_order.rb
class StoreOrder < ApplicationRecord
  belongs_to :user
  belongs_to :seller, class_name: 'User'
  has_many :order_items, dependent: :destroy

  scope :recent, -> { order(created_at: :desc) }
  scope :pending, -> { where(status: 'pending') }

  def self.monthly_revenue
    where('created_at >= ?', 1.month.ago)
      .sum('total')
  end

  enum status: {
    pending: 'pending',
    processing: 'processing',
    shipped: 'shipped',
    delivered: 'delivered',
    cancelled: 'cancelled'
  }
end