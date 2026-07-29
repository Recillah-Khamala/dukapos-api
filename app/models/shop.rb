class Shop < ApplicationRecord
  has_many :customers
  has_many :inventory_items
  has_many :sales
  has_many :credit_entries
  validates :name, presence: true
end
