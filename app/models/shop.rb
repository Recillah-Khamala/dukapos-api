class Shop < ApplicationRecord
  has_many :customers
  has_many :inventory_items
  has_many :sales
  validates :name, presence: true
end
