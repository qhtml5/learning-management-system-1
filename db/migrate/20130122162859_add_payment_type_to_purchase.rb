class AddPaymentTypeToPurchase < ActiveRecord::Migration
  def change
  	add_column :purchases, :payment_type, :string
  end
end
