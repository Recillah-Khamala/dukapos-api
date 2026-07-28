class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items, id: :uuid do |t|
      t.references :shop, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :current_stock, precision: 10, scale: 2, null: false, default: 0
      t.string :buying_unit, null: false
      t.string :selling_unit, null: false
      t.decimal :conversion_rate, precision: 10, scale: 4, null: false
      t.decimal :low_stock_threshold, precision: 10, scale: 2, null: false, default: 0
      t.string :category, null: false
      t.text :description
      t.string :icon
      t.decimal :buying_price, precision: 10, scale: 2
      t.timestamps
    end
  end
end
