class CreateSaleItems < ActiveRecord::Migration[8.0]
  def change
    create_table :sale_items, id: :uuid do |t|
      t.references :sale, type: :uuid, null: false, foreign_key: true
      t.references :inventory_item, type: :uuid, null: true, foreign_key: true
      t.string :name, null: false
      t.decimal :qty, precision: 10, scale: 2, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.string :item_type, null: false
      t.string :icon
      t.boolean :is_service, default: false, null: false
      t.string :unit_type
      t.string :fraction_label
      t.string :unit_label
      t.string :variant_label
      t.timestamps
    end
  end
end
