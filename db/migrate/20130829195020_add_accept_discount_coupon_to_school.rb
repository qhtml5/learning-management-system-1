class AddAcceptDiscountCouponToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :cart_recovery, :boolean, default: false
  end
end
