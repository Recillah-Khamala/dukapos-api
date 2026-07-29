class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales, id: :uuid do |t|
      t.references :shop, type: :uuid, null: false, foreign_key: true
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :payment_method, null: false
      t.datetime :completed_at, null: false
      t.timestamps
    end
  end
end
