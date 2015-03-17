class RemoveDiscountFromPurchase < ActiveRecord::Migration
  def up
    remove_column :purchases, :discount
  end

  def down
    add_column :purchases, :discount, :string
  end
end
