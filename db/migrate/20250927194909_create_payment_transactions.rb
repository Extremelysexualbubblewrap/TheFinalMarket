class CreatePaymentTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :payment_transactions do |t|
      t.references :source_account, null: false, foreign_key: { to_table: :payment_accounts }
      t.references :target_account, foreign_key: { to_table: :payment_accounts }
      t.references :order, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_type, null: false
      t.string :status, null: false, default: 'pending'
      t.string :stripe_transaction_id
      t.string :stripe_refund_id
      t.text :description
      t.jsonb :metadata, default: {}
      t.datetime :processed_at

      t.timestamps

      t.index :transaction_type
      t.index :status
      t.index :stripe_transaction_id
      t.index :processed_at
    end
  end
end
