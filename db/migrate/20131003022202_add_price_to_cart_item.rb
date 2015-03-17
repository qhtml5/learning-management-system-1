class AddPriceToCartItem < ActiveRecord::Migration
  def change
    add_column :cart_items, :price, :integer, default: 0
  end
end
