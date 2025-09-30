class SellerStatsService
  def self.update_stats(seller)
    new(seller).update_stats
  end

  def initialize(seller)
    @seller = seller
  end

  def update_stats
    ActiveRecord::Base.transaction do
      update_monthly_sales
      update_total_sales
      update_seller_tier
      @seller.update!(last_sales_update: Time.current)
    end
  end

  private

  def update_monthly_sales
    monthly_sales = @seller.orders
                          .where('created_at > ?', 30.days.ago)
                          .where(status: :completed)
                          .sum(:total_amount_cents)

    @seller.update!(monthly_sales_cents: monthly_sales)
  end

  def update_total_sales
    total_sales = @seller.orders
                        .where(status: :completed)
                        .sum(:total_amount_cents)

    @seller.update!(total_sales_cents: total_sales)
  end

  def update_seller_tier
    new_tier = calculate_tier
    return if @seller.seller_tier == new_tier

    @seller.update!(seller_tier: new_tier)
    notify_tier_change(new_tier)
  end

  def calculate_tier
    monthly_sales = Money.new(@seller.monthly_sales_cents)
    total_sales = Money.new(@seller.total_sales_cents)
    rating = @seller.average_rating

    if monthly_sales >= Money.new(25_000_000) && # $250,000
       total_sales >= Money.new(100_000_000) && # $1,000,000
       rating >= 4.8
      'premium'
    elsif monthly_sales >= Money.new(10_000_000) && # $100,000
          total_sales >= Money.new(50_000_000) && # $500,000
          rating >= 4.5
      'high_volume'
    else
      'standard'
    end
  end

  def notify_tier_change(new_tier)
    NotificationService.notify(
      user: @seller,
      title: "Seller Tier Updated",
      body: "Congratulations! You've been upgraded to #{new_tier} seller status.",
      category: :account_update
    )
  end
end