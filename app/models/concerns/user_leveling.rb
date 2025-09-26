module UserLeveling
  extend ActiveSupport::Concern

  included do
    after_create :check_level_up
    after_save :check_level_up, if: :points_changed?
  end

  # Points required for each level
  LEVEL_THRESHOLDS = {
    1 => 0,      # Garnet
    2 => 100,    # Topaz
    3 => 300,    # Emerald
    4 => 600,    # Sapphire
    5 => 1000,   # Ruby
    6 => 2000    # Diamond
  }.freeze

  # Points awarded for different actions
  POINT_AWARDS = {
    successful_sale: 10,        # Points for each successful sale
    positive_review: 5,         # Points for each positive review (4-5 stars)
    neutral_review: 2,          # Points for neutral review (3 stars)
    product_listed: 3,          # Points for listing a new product
    days_active: 1,             # Points per day of activity
    monthly_bonus: 30,          # Monthly active seller bonus
    perfect_month: 50,          # Bonus for perfect reviews in a month
    quick_response: 2,          # Quick response to customer messages
    dispute_resolved: 5         # Successfully resolved dispute
  }.freeze

  def check_level_up
    current_level = level
    new_level = calculate_level
    
    if new_level > current_level
      update_column(:level, new_level) # Use update_column to avoid recursive callbacks
      notify_level_up(new_level)
    end
  end

  def add_points(action)
    if POINT_AWARDS.key?(action)
      self.points += POINT_AWARDS[action]
      save
    end
  end

  def points_to_next_level
    next_level = level + 1
    return 0 if next_level > 6
    LEVEL_THRESHOLDS[next_level] - points
  end

  def progress_to_next_level
    return 100 if level >= 6
    
    current_level_points = LEVEL_THRESHOLDS[level]
    next_level_points = LEVEL_THRESHOLDS[level + 1]
    points_needed = next_level_points - current_level_points
    points_earned = points - current_level_points
    
    [(points_earned.to_f / points_needed * 100), 100].min
  end

  private

  def calculate_level
    LEVEL_THRESHOLDS.to_a.reverse.find { |level, points| self.points >= points }&.first || 1
  end

  def notify_level_up(new_level)
    notifications.create!(
      actor: self,
      action: "level_up",
      notifiable: self,
      message: "Congratulations! You've reached #{level_name} level!"
    )
  end
end