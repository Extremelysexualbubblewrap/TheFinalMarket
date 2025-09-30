class CreateEscrowHolds < ActiveRecord::Migration[8.0]
  def change
    create_table :escrow_holds do |t|
      t.references :payment_account, null: false, foreign_key: true
      t.references :order, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :reason, null: false
      t.string :status, null: false, default: 'active'
      t.datetime :released_at
      t.datetime :expires_at

      t.timestamps

      t.index :status
      t.index :released_at
      t.index :expires_at
    end
  end
end
