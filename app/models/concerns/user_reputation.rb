module UserReputation
  extend ActiveSupport::Concern

  included do
    has_many :reputation_events, class_name: 'UserReputationEvent', dependent: :destroy
  end

  def reputation_score
    reputation_events.sum(:points)
  end

  def reputation_level
    case reputation_score
    when ...-50 then :restricted
    when -49..0 then :probation
    when 1..100 then :regular
    when 101..500 then :trusted
    else :exemplary
    end
  end

  def add_reputation_points(points, reason)
    reputation_events.create!(points: points, reason: reason)
  end

  def can_post_content?
    reputation_level != :restricted
  end

  private

  def record_reputation_event(points, reason)
    reputation_events.create!(
      points: points,
      reason: reason
    )
  end
end