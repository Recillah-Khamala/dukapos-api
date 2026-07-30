class CreditEntry < ApplicationRecord
  belongs_to :shop
  belongs_to :customer
  has_many :credit_entry_items, dependent: :destroy

  VALID_STATUSES = %w[active paid].freeze

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :amount_paid, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: VALID_STATUSES }
end
