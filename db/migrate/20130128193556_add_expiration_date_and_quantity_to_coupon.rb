class AddExpirationDateAndQuantityToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :expiration_date, :datetime
    add_column :coupons, :quantity, :integer
  end
end
