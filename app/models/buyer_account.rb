# app/models/buyer_account.rb
class BuyerAccount < PaymentAccount
  include SquareAccount
  has_many :purchase_transactions, class_name: 'PaymentTransaction', foreign_key: 'source_account_id'
  
  def process_purchase(order)
    total_amount = order.total_amount
    
    with_lock do
      if available_balance >= total_amount
        transaction do
          # Create escrow hold
          hold_funds(total_amount, "Order ##{order.id}")
          
          # Create purchase transaction
          purchase_transactions.create!(
            amount: total_amount,
            target_account: order.seller.seller_account,
            order: order,
            transaction_type: 'purchase',
            status: 'held'
          )
        end
        true
      else
        false
      end
    end
  end

  def process_refund(order)
    transaction do
      # Release held funds back to buyer
      release_funds(order.total_amount, "Refund for Order ##{order.id}")
      
      # Update transaction status
      transaction = purchase_transactions.find_by(order: order)
      transaction&.update!(status: 'refunded')
    end
  end

  private

  def stripe_account_type
    'customer'
  end
end