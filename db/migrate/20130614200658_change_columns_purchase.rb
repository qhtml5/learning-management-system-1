class ChangeColumnsPurchase < ActiveRecord::Migration
  def up
  	change_column :purchases, :amount_paid, :integer
  end

  def down
  	change_column :purchases, :amount_paid, :float
  end
end
