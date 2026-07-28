class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops, id: :uuid do |t|
      t.timestamps
    end
  end
end
