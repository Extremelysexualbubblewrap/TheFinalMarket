class ProductView < ApplicationRecord
  belongs_to :user
  belongs_to :product
  
  validates :user_id, presence: true
  validates :product_id, presence: true
  
  # Keep only recent views
  after_create :cleanup_old_views
  
  private
  
  def cleanup_old_views
    user.product_views
      .order(created_at: :desc)
      .offset(100) # Keep last 100 views
      .destroy_all
  end
end