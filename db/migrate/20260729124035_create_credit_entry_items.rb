class CreateCreditEntryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_entry_items, id: :uuid do |t|
      t.timestamps
    end
  end
end
