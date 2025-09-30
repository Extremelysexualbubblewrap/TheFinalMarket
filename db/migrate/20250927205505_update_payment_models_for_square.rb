class UpdatePaymentModelsForSquare < ActiveRecord::Migration[8.0]
  def change
    # Update PaymentAccount model
    add_column :payment_accounts, :square_account_id, :string
    add_column :payment_accounts, :business_email, :string
    add_column :payment_accounts, :merchant_name, :string
    add_index :payment_accounts, :square_account_id, unique: true

    # Remove Stripe-specific columns
    remove_column :payment_accounts, :stripe_customer_id, :string, if_exists: true
    remove_column :payment_accounts, :stripe_connect_id, :string, if_exists: true
    remove_column :payment_accounts, :stripe_external_account_id, :string, if_exists: true

    # Update PaymentTransaction model
    add_column :payment_transactions, :square_payment_id, :string
    add_column :payment_transactions, :square_refund_id, :string
    add_column :payment_transactions, :square_transfer_id, :string
    add_index :payment_transactions, :square_payment_id, unique: true
    add_index :payment_transactions, :square_refund_id, unique: true
    add_index :payment_transactions, :square_transfer_id, unique: true

    # Remove Stripe-specific columns
    remove_column :payment_transactions, :stripe_transaction_id, :string, if_exists: true
    remove_column :payment_transactions, :stripe_refund_id, :string, if_exists: true
    remove_column :payment_transactions, :stripe_transfer_id, :string, if_exists: true
    remove_column :payment_transactions, :stripe_payout_id, :string, if_exists: true
  end
end
