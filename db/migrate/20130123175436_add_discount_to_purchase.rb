class AddDiscountToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :discount, :integer
  end
end
