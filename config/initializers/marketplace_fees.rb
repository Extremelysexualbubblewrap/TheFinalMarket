# frozen_string_literal: true

# Configuration for marketplace fees
module MarketplaceFees
  mattr_accessor :fee_tiers do
    [
      { min_amount: 0,      max_amount: 5000,    percentage: 0.10, fixed: 30 },   # 10% + $0.30 for orders up to $50
      { min_amount: 5001,   max_amount: 10000,   percentage: 0.08, fixed: 30 },   # 8% + $0.30 for orders $50.01-$100
      { min_amount: 10001,  max_amount: 50000,   percentage: 0.06, fixed: 30 },   # 6% + $0.30 for orders $100.01-$500
      { min_amount: 50001,  max_amount: 100000,  percentage: 0.05, fixed: 30 },   # 5% + $0.30 for orders $500.01-$1000
      { min_amount: 100001, max_amount: nil,     percentage: 0.04, fixed: 30 }    # 4% + $0.30 for orders above $1000
    ]
  end

  mattr_accessor :seller_tiers do
    {
      new_seller: { discount: 0.00 },      # No discount for new sellers
      bronze: { discount: 0.05 },          # 5% discount on fees
      silver: { discount: 0.10 },          # 10% discount on fees
      gold: { discount: 0.15 },            # 15% discount on fees
      platinum: { discount: 0.20 }         # 20% discount on fees
    }
  end

  mattr_accessor :category_modifiers do
    {
      default: 0.00,                       # No modifier for most categories
      high_risk: 0.02,                     # +2% for high-risk categories
      luxury: 0.01,                        # +1% for luxury items
      low_margin: -0.01                    # -1% for low-margin categories
    }
  end

  mattr_accessor :payment_processing_fee do
    {
      percentage: 0.029,                   # 2.9% for card processing
      fixed: 30                            # $0.30 per transaction
    }
  end

  def self.configure
    yield self if block_given?
  end
end