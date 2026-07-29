class Customer < ApplicationRecord
  belongs_to :shop
  has_many :credit_entries
  validates :name, presence: true
end
