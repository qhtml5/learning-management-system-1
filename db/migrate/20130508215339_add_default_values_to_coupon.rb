class AddDefaultValuesToCoupon < ActiveRecord::Migration
  def up
  	change_column :coupons, :discount, :integer, default: 0
  	change_column :coupons, :quantity, :integer, default: 0
  end

  def down
  	change_column :coupons, :discount, :integer
  	change_column :coupons, :quantity, :integer
  end
end
