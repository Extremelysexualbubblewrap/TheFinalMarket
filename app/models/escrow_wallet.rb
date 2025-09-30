class EscrowWallet < ApplicationRecord
  belongs_to :user
  has_many :escrow_transactions
  has_many :held_orders, class_name: 'Order', foreign_key: 'escrow_wallet_id'

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, presence: true, uniqueness: true

  def hold_funds(amount)
    with_lock do
      if balance >= amount
        self.balance -= amount
        self.held_balance += amount
        save!
        true
      else
        false
      end
    end
  end

  def release_funds(amount)
    with_lock do
      if held_balance >= amount
        self.held_balance -= amount
        save!
        true
      else
        false
      end
    end
  end

  def receive_funds(amount)
    with_lock do
      self.balance += amount
      save!
    end
  end

  def withdraw_funds(amount)
    with_lock do
      if balance >= amount
        self.balance -= amount
        save!
        true
      else
        false
      end
    end
  end
end