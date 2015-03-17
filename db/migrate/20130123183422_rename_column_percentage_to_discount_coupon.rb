class RenameColumnPercentageToDiscountCoupon < ActiveRecord::Migration
  def up
  	rename_column :coupons, :percentage, :discount
  end

  def down
  	rename_column :coupons, :discount, :percentage 
  end
end
