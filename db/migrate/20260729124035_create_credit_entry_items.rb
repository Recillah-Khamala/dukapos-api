class CreateCreditEntryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_entry_items, id: :uuid do |t|
      t.references :credit_entry, type: :uuid, null: false, foreign_key: true
      t.references :inventory_item, type: :uuid, null: true, foreign_key: true
      t.string :name, null: false
      t.decimal :qty, precision: 10, scale: 2, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :category
      t.decimal :amount_paid, precision: 10, scale: 2, default: 0
      t.decimal :balance, precision: 10, scale: 2
      t.string :unit
      t.timestamps
    end
  end
end
