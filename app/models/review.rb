class Review < ApplicationRecord
  include ContentFilterable

  # Associations
  belongs_to :reviewer, class_name: 'User'
  belongs_to :reviewable, polymorphic: true
  has_many :helpful_votes, dependent: :destroy

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :reviewer_id, uniqueness: { 
    scope: [:reviewable_type, :reviewable_id],
    message: "can only review once"
  }
  validate :cannot_review_own_item
  validate :must_have_purchased_item, if: :item_review?
  validate :must_have_transaction_with_seller, if: :seller_review?

  # Callbacks
  after_create :update_reviewable_rating
  after_create :award_points
  after_create_commit :notify_owner

  # Scopes
  scope :for_items, -> { where(reviewable_type: 'Item') }
  scope :for_sellers, -> { where(reviewable_type: 'User') }
  scope :helpful, -> { where('helpful_count > 0') }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, -> { order(rating: :desc) }

  def helpful!(user)
    helpful_votes.create!(user: user)
    increment!(:helpful_count)
  end

  def unhelpful!(user)
    helpful_votes.find_by(user: user)&.destroy
    decrement!(:helpful_count)
  end

  private

  def filtered_fields
    [:content]
  end

  def cannot_review_own_item
    if item_review? && reviewable.user_id == reviewer_id
      errors.add(:base, "You cannot review your own item")
    end
  end

  def must_have_purchased_item
    unless OrderItem.exists?(item: reviewable, order: { user_id: reviewer_id })
      errors.add(:base, "You must purchase this item before reviewing it")
    end
  end

  def must_have_transaction_with_seller
    if reviewable_type == 'User' && !Order.joins(:items)
        .where(user_id: reviewer_id, items: { user_id: reviewable_id })
        .exists?
      errors.add(:base, "You must have completed a transaction with this seller to review them")
    end
  end

  def update_reviewable_rating
    avg_rating = Review.where(reviewable: reviewable).average(:rating) || 0
    
    if reviewable_type == 'User'
      reviewable.update(seller_rating: avg_rating)
    else
      reviewable.update(rating: avg_rating)
    end
  end

  def award_points
    points = calculate_review_points
    reviewer.increment!(:points, points)
    
    # Award points to the item/seller owner for receiving a review
    if rating >= 4
      owner_points = rating * 5 # More points for better ratings
      reviewable.user.increment!(:points, owner_points)
    end
  end

  def calculate_review_points
    base_points = 10
    points = base_points

    # Bonus points for detailed reviews
    points += 5 if content.length >= 100
    points += 5 if content.length >= 200

    # Bonus for adding first review
    points += 10 unless Review.exists?(reviewable: reviewable)

    points
  end

  def notify_owner
    owner = reviewable_type == 'User' ? reviewable : reviewable.user
    owner.notify(
      actor: reviewer,
      action: 'new_review',
      notifiable: self
    )
  end

  def item_review?
    reviewable_type == 'Item'
  end

  def seller_review?
    reviewable_type == 'User'
  end
end