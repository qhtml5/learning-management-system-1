class AddCouponIdToCartItem < ActiveRecord::Migration
  def up
    add_column :cart_items, :coupon_id, :integer
    add_column :cart_items, :purchase_id, :integer
    add_column :courses_purchases, :coupon_id, :integer
    add_column :coupons, :course_id, :integer
    remove_column :carts, :coupon_id
    remove_column :purchases, :coupon_id
  end

  def down
  	remove_column :cart_items, :coupon_id
    remove_column :cart_items, :purchase_id
    remove_column :courses_purchases, :coupon_id
  	remove_column :coupons, :course_id
  	add_column :carts, :coupon_id, :integer
  	add_column :purchases, :coupon_id, :integer
  end
end
