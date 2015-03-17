class AddCouponIdToCart < ActiveRecord::Migration
  def change
    add_column :carts, :coupon_id, :integer
  end
end
