class BondTransaction < ApplicationRecord
  belongs_to :bond
  belongs_to :payment_transaction, optional: true

  monetize :amount_cents

  validates :transaction_type, presence: true
  validates :amount_cents, presence: true, numericality: { greater_than: 0 }
end
