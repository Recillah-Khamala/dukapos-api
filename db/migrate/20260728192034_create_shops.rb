class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops, id: :uuid do |t|
      t.string :name, null: false
      t.string :location
      t.string :shop_type, default: 'cereal', null: false
      t.timestamps
    end
  end
end
