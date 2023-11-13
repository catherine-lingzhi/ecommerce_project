class RemoveBooleanColumnsFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :on_sale, :boolean
    remove_column :products, :new, :boolean
    remove_column :products, :recently_updated, :boolean
  end
end
