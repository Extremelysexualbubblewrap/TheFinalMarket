class FeeCalculatorService
  # Fee types
  FEE_TYPES = {
    standard: {
      percentage: 5.0,    # 5% base fee
      minimum: Money.new(50)  # $0.50 minimum
    },
    high_volume: {
      percentage: 4.0,    # 4% for high volume sellers
      minimum: Money.new(50)
    },
    premium: {
      percentage: 3.0,    # 3% for premium sellers
      minimum: Money.new(50)
    }
  }.freeze

  # Category multipliers
  CATEGORY_MULTIPLIERS = {
    digital: 1.2,    # Digital goods have higher fees
    physical: 1.0,   # Standard rate for physical goods
    services: 1.1    # Slightly higher for services
  }.freeze

  def initialize(seller, order)
    @seller = seller
    @order = order
  end

  def calculate_fee
    base_fee = calculate_base_fee
    category_adjusted_fee = apply_category_multiplier(base_fee)
    volume_adjusted_fee = apply_volume_discounts(category_adjusted_fee)
    
    # Never go below minimum fee
    [volume_adjusted_fee, minimum_fee].max
  end

  private

  def calculate_base_fee
    fee_type = determine_fee_type
    percentage = FEE_TYPES[fee_type][:percentage]
    
    # Calculate raw fee amount
    (@order.total_amount * (percentage / 100.0))
  end

  def determine_fee_type
    return :premium if @seller.premium_seller?
    return :high_volume if high_volume_seller?
    :standard
  end

  def high_volume_seller?
    # Check last 30 days sales
    total_sales = @seller.orders
                        .where('created_at > ?', 30.days.ago)
                        .where(status: :completed)
                        .sum(:total_amount_cents)
    
    Money.new(total_sales) >= Money.new(1_000_000) # $10,000
  end

  def apply_category_multiplier(base_fee)
    multiplier = CATEGORY_MULTIPLIERS[@order.product.category.fee_type.to_sym] || 1.0
    base_fee * multiplier
  end

  def apply_volume_discounts(fee)
    # Additional volume-based discounts
    monthly_sales = @seller.orders
                          .where('created_at > ?', 30.days.ago)
                          .where(status: :completed)
                          .sum(:total_amount_cents)
    
    discount = case Money.new(monthly_sales)
              when Money.new(5_000_000)..Money.new(10_000_000)   # $50,000 - $100,000
                0.9  # 10% discount
              when Money.new(10_000_001)..Money.new(25_000_000)  # $100,000 - $250,000
                0.85 # 15% discount
              when Money.new(25_000_001)..Float::INFINITY        # Over $250,000
                0.8  # 20% discount
              else
                1.0  # No discount
              end
    
    fee * discount
  end

  def minimum_fee
    FEE_TYPES[determine_fee_type][:minimum]
  end
end