class ChangeColumnAutomaticInCoupon < ActiveRecord::Migration
  def up
  	change_column :coupons, :automatic, :boolean, default: false
  	Coupon.where(automatic: nil).update_all(automatic: false)
  end

  def down
  	change_column :coupons, :automatic, :boolean
  end
end
