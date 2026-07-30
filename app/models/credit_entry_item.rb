class CreditEntryItem < ApplicationRecord
  belongs_to :credit_entry
  belongs_to :inventory_item, optional: true

  validates :name, presence: true
  validates :qty, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total, presence: true, numericality: { greater_than: 0 }
end
