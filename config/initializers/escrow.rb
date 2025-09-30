# config/initializers/escrow.rb

Rails.application.configure do
  # Number of days to hold funds in escrow before automatic release
  config.escrow_expiry_days = 14
  
  # Maximum amount in cents that can be held in escrow per transaction
  config.max_escrow_amount = 1_000_000 # $10,000
  
  # Minimum amount in cents that requires escrow
  config.min_escrow_amount = 5_000 # $50
  
  # Fee structure for escrow services (percentage as decimal)
  config.escrow_fee_percentage = 0.02 # 2%
  
  # Maximum fee in cents that can be charged for escrow
  config.max_escrow_fee = 50_000 # $500
end