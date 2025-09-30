class CreateDisputeResolutions < ActiveRecord::Migration[8.0]
  def change
    create_table :dispute_resolutions do |t|
      t.integer :resolution_type, null: false
      t.text :notes, null: false
      t.decimal :refund_amount, precision: 10, scale: 2
      t.references :dispute, null: false, foreign_key: true
      t.datetime :implemented_at

      t.timestamps
    end

    add_index :dispute_resolutions, :resolution_type
  end
end
