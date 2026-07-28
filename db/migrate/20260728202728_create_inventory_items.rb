class CreateInventoryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_items, id: :uuid do |t|
      t.timestamps
    end
  end
end
