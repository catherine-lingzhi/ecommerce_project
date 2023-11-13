class Product < ApplicationRecord
  belongs_to :category
  belongs_to :product_status
end
