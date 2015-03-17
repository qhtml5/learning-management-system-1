class ChangeColumnAmountPaidOnPurchase < ActiveRecord::Migration
  def up
  	change_column :purchases, :amount_paid, :integer, default: 0
  	change_column :purchases, :moip_tax, :integer, default: 0
  end

  def down
  	change_column :purchases, :amount_paid, :integer
  	change_column :purchases, :moip_tax, :integer, default: 0
  end
end
