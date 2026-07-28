class InventoryFractionPrice < ApplicationRecord
  belongs_to :inventory_item

  validates :label, presence: true
  validates :fraction, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
  validates :price, presence: true, numericality: { greater_than: 0 }
end
