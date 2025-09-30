class CreateBondTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :bond_transactions do |t|
      t.references :bond, null: false, foreign_key: true
      t.references :payment_transaction, null: true, foreign_key: true
      t.string :transaction_type # payment, refund, forfeiture
      t.monetize :amount
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :bond_transactions, :transaction_type
  end
end
