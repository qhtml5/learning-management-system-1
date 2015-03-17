class AddQuantityLeftToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :quantity_left, :integer
  end
end
