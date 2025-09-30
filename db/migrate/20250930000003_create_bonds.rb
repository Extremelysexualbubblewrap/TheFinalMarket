class CreateBonds < ActiveRecord::Migration[8.0]
  def change
    create_table :bonds do |t|
      t.references :user, null: false, foreign_key: true
      t.monetize :amount
      t.string :status
      t.datetime :paid_at
      t.datetime :forfeited_at
      t.datetime :returned_at
      t.text :forfeiture_reason

      t.timestamps
    end

    add_index :bonds, :status
  end
end
