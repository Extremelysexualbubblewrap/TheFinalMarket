class Item < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
  has_many_attached :images

  # Enums
  enum status: {
    draft: 0,
    active: 1,
    sold: 2,
    inactive: 3
  }

  enum condition: {
    new_with_tags: 0,
    new_without_tags: 1,
    like_new: 2,
    very_good: 3,
    good: 4,
    acceptable: 5
  }

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true
  validates :condition, presence: true
  validates :images, content_type: [:png, :jpg, :jpeg], size: { less_than: 5.megabytes }

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :by_seller, ->(user_id) { where(user_id: user_id) }
  scope :price_range, ->(min, max) { where(price: min..max) }

  # Callbacks
  before_validation :set_default_status, on: :create

  def average_rating
    reviews.average(:rating) || 0
  end

  private

  def set_default_status
    self.status ||= :draft
  end
end
