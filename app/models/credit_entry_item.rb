class CreditEntryItem < ApplicationRecord
  belongs_to :credit_entry
  belongs_to :inventory_item, optional: true

  VALID_CATEGORIES = %w[cereal milling bags other].freeze

  validates :name, presence: true
  validates :qty, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total, presence: true, numericality: { greater_than: 0 }
  validates :category, inclusion: { in: VALID_CATEGORIES }, allow_nil: true
  validates :amount_paid, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
