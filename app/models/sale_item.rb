class SaleItem < ApplicationRecord
  belongs_to :sale
  belongs_to :inventory_item, optional: true

  VALID_ITEM_TYPES = %w[cereal service bag].freeze

  validates :name, presence: true
  validates :qty, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :item_type, inclusion: { in: VALID_ITEM_TYPES }
end
