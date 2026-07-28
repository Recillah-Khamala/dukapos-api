class InventoryItem < ApplicationRecord
  belongs_to :shop
  has_many :inventory_fraction_prices, dependent: :destroy

  VALID_CATEGORIES = %w[cereal poshomill bags].freeze

  validates :name, presence: true
  validates :buying_unit, presence: true
  validates :selling_unit, presence: true
  validates :conversion_rate, presence: true, numericality: { greater_than: 0 }
  validates :category, inclusion: { in: VALID_CATEGORIES }
end
