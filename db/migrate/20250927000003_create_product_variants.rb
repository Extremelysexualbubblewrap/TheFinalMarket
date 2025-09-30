class CreateProductVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :option_types do |t|
      t.string :name, null: false
      t.references :product, null: false, foreign_key: true
      t.integer :position, default: 0
      t.timestamps
    end

    add_index :option_types, [:product_id, :name], unique: true

    create_table :option_values do |t|
      t.string :name, null: false
      t.references :option_type, null: false, foreign_key: true
      t.integer :position, default: 0
      t.timestamps
    end

    add_index :option_values, [:option_type_id, :name], unique: true

    create_table :variants do |t|
      t.string :sku, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, null: false, default: 0
      t.references :product, null: false, foreign_key: true
      t.timestamps
    end

    add_index :variants, :sku, unique: true

    create_table :variant_option_values do |t|
      t.references :variant, null: false, foreign_key: true
      t.references :option_value, null: false, foreign_key: true
      t.timestamps
    end

    add_index :variant_option_values, [:variant_id, :option_value_id], unique: true
  end
end
