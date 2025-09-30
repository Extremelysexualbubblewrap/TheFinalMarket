class CreatePaymentAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :balance, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :held_balance, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :available_balance, precision: 10, scale: 2, default: 0.0, null: false
      t.string :stripe_customer_id
      t.string :stripe_connect_id
      t.string :stripe_external_account_id
      t.string :status, null: false, default: 'pending'
      t.string :type, null: false
      t.jsonb :payment_methods, default: {}
      t.datetime :last_payout_at
      t.string :currency, default: 'USD', null: false

      t.timestamps

      t.index :stripe_customer_id
      t.index :stripe_connect_id
      t.index :status
      t.index :type
    end
  end
end
