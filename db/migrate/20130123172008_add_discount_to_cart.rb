class AddDiscountToCart < ActiveRecord::Migration
  def change
    add_column :carts, :discount, :integer
  end
end
