class ChangeColumnTaxaMoipOnPurchase < ActiveRecord::Migration
  def up
  	change_column :purchases, :moip_tax, :float, default: 0
  	add_column :purchases, :commission, :integer, default: 0
  end

  def down
  	change_column :purchases, :moip_tax, :integer, default: 0
  	remove_column :purchases, :commission
  end
end
