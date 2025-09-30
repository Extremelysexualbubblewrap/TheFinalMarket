class CreateEscrowTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :escrow_transactions do |t|
      t.references :order, null: false, foreign_key: true
      t.references :payment_transaction, null: false, foreign_key: true
      t.references :buyer_account, null: false, foreign_key: { to_table: :payment_accounts }
      t.references :seller_account, null: false, foreign_key: { to_table: :payment_accounts }
      t.monetize :amount
      t.monetize :fee
      t.datetime :release_at
      t.string :status
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :escrow_transactions, :status
    add_index :escrow_transactions, :release_at
  end
end
