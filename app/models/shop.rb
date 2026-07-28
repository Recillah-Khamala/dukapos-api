class Shop < ApplicationRecord
  has_many :customers
  has_many :inventory_items
  validates :name, presence: true
end
