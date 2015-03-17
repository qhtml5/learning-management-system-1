class RemoveDiscountFromCart < ActiveRecord::Migration
  def up
    remove_column :carts, :discount
  end

  def down
    add_column :carts, :discount, :string
  end
end
