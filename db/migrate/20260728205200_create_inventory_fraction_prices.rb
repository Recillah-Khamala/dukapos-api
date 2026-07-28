class CreateInventoryFractionPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_fraction_prices, id: :uuid do |t|
      t.references :inventory_item, type: :uuid, null: false, foreign_key: true
      t.string :label, null: false
      t.decimal :fraction, precision: 10, scale: 4, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.timestamps
    end
  end
end
