class AddInstallmentsToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :installments, :integer, default: 1
  end
end
