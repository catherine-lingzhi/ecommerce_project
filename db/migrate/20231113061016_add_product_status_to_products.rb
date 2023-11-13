class AddProductStatusToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :product_status, null: false, foreign_key: true
  end
end
