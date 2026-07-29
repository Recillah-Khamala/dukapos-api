class Sale < ApplicationRecord
  belongs_to :shop
  has_many :sale_items, dependent: :destroy

  VALID_PAYMENT_METHODS = %w[cash mpesa credit].freeze

  validates :total, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: VALID_PAYMENT_METHODS }
  validates :completed_at, presence: true
end
