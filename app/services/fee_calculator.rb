class FeeCalculator
  def initialize(order)
    @order = order
    @amount = order.total_amount
    @seller = order.seller
    @category = order.primary_category
  end

  def calculate_total_fees
    {
      marketplace_fee: calculate_marketplace_fee,
      processing_fee: calculate_processing_fee,
      total_fee: total_fee
    }
  end

  private

  def calculate_marketplace_fee
    base_fee = calculate_base_fee
    discount = apply_seller_discount(base_fee)
    modifier = apply_category_modifier(base_fee)
    
    base_fee - discount + modifier
  end

  def calculate_base_fee
    tier = find_fee_tier
    percentage_fee = @amount * tier[:percentage]
    fixed_fee = Money.new(tier[:fixed])
    
    percentage_fee + fixed_fee
  end

  def find_fee_tier
    MarketplaceFees.fee_tiers.find do |tier|
      amount_cents = @amount.cents
      min_cents = tier[:min_amount]
      max_cents = tier[:max_amount]

      if max_cents.nil?
        amount_cents >= min_cents
      else
        amount_cents >= min_cents && amount_cents <= max_cents
      end
    end
  end

  def apply_seller_discount(base_fee)
    tier = MarketplaceFees.seller_tiers[@seller.tier.to_sym]
    return Money.new(0) unless tier

    base_fee * tier[:discount]
  end

  def apply_category_modifier(base_fee)
    modifier = MarketplaceFees.category_modifiers[@category.fee_type.to_sym] || 
              MarketplaceFees.category_modifiers[:default]
    
    @amount * modifier
  end

  def calculate_processing_fee
    fee_config = MarketplaceFees.payment_processing_fee
    percentage_fee = @amount * fee_config[:percentage]
    fixed_fee = Money.new(fee_config[:fixed])
    
    percentage_fee + fixed_fee
  end

  def total_fee
    calculate_marketplace_fee + calculate_processing_fee
  end
end