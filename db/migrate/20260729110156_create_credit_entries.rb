class CreateCreditEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_entries, id: :uuid do |t|
      t.references :shop, type: :uuid, null: false, foreign_key: true
      t.references :customer, type: :uuid, null: false, foreign_key: true
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.decimal :amount_paid, precision: 10, scale: 2, null: false, default: 0
      t.decimal :balance, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'active'
      t.timestamps
    end
  end
end
