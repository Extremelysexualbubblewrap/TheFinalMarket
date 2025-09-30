# app/models/seller_account.rb
class SellerAccount < PaymentAccount
  has_many :received_transactions, class_name: 'PaymentTransaction', foreign_key: 'target_account_id'
  has_many :payouts, dependent: :restrict_with_error
  
  include SquareAccount
  
  validates :business_email, presence: true, email: true, if: :active?
  validates :merchant_name, presence: true, if: :active?

  def eligible_for_payout?
    active? && 
    available_balance.positive? && 
    (last_payout_at.nil? || last_payout_at < 7.days.ago)
  end

  def process_payout
    return false unless eligible_for_payout?

    amount = available_balance
    
    transaction do
      payout = payouts.create!(
        amount: amount,
        status: 'pending',
        stripe_payout_id: nil
      )
      
      PayoutJob.perform_later(payout)
      update!(last_payout_at: Time.current)
    end
    true
  end

  def release_bond
    return false unless held_balance.positive?

    transaction do
      release_funds(held_balance, "Bond release")
      update!(status: :closed)
    end
    true
  end

  def accept_payment(transaction)
    with_lock do
      if transaction.status == 'held'
        self.available_balance += transaction.amount
        save!
        transaction.update!(status: 'completed')
        true
      else
        false
      end
    end
  end

  private

  def stripe_account_type
    'connect'
  end
end