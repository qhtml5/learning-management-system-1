class AddCouponIdToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :coupon_id, :integer
  end
end
