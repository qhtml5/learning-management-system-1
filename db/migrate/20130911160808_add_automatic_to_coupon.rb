class AddAutomaticToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :automatic, :boolean
  end
end
