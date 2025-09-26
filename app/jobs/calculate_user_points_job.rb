class CalculateUserPointsJob < ApplicationJob
  queue_as :default

  def perform
    calculate_daily_points
    calculate_monthly_points if Time.current.day == 1 # Run monthly calculations on the first day of each month
  end

  private

  def calculate_daily_points
    User.find_each do |user|
      # Daily active seller points
      if user.gem? && user.seller_status == 'approved'
        user.add_points(:days_active)
      end

      # Quick response points (if responded to all messages within 24 hours)
      if user.gem? && quick_responder?(user)
        user.add_points(:quick_response)
      end
    end
  end

  def calculate_monthly_points
    User.find_each do |user|
      next unless user.gem? && user.seller_status == 'approved'

      # Monthly active seller bonus
      if monthly_active_seller?(user)
        user.add_points(:monthly_bonus)
      end

      # Perfect month bonus (all 5-star reviews)
      if perfect_month?(user)
        user.add_points(:perfect_month)
      end
    end
  end

  def quick_responder?(user)
    # Implement logic to check if user responded to all messages within 24 hours
    true # Placeholder - implement message response tracking
  end

  def monthly_active_seller?(user)
    user.products.where('created_at >= ?', 1.month.ago).exists? ||
    user.products.joins(:orders).where('orders.created_at >= ?', 1.month.ago).exists?
  end

  def perfect_month?(user)
    reviews = user.products.joins(:reviews)
                 .where('reviews.created_at >= ?', 1.month.ago)
    
    reviews.any? && reviews.all? { |r| r.rating == 5 }
  end
end