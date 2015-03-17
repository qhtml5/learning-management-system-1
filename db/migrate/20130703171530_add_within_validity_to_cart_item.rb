class AddWithinValidityToCartItem < ActiveRecord::Migration
  def change
    add_column :cart_items, :within_validity, :boolean, default: true
  end
end
