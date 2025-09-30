module SellerFeesConcern
  extend ActiveSupport::Concern

  included do
    scope :seller, -> { where(seller: true) }

    monetize :total_sales_cents
    monetize :monthly_sales_cents
  end

  def premium_seller?
    seller_tier == 'premium'
  end

  def high_volume_seller?
    seller_tier == 'high_volume'
  end

  def standard_seller?
    seller_tier == 'standard'
  end

  def calculate_fee_for_order(order)
    FeeCalculatorService.new(self, order).calculate_fee
  end

  def update_seller_stats
    UpdateSellerStatsJob.perform_later(self)
  end
end