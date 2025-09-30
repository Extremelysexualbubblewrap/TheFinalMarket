class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :description
      t.string :slug
      t.integer :products_count, default: 0

      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true
  end
end