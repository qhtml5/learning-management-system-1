class ChangeTablePurchase < ActiveRecord::Migration
  def up
  	drop_table :purchases

  	create_table :purchases do |t|
  		t.string :status
  		t.integer :code
  		t.string :return_code
  		t.float :moip_tax
  		t.string :payment_status
  		t.string :description
  		t.integer :moip_code
  		t.string :message
  		t.float :amount_paid
  		t.integer :user_id
  	end
  end

  def down
  	drop_table :purchases

		create_table "purchases" do |t|
	    t.string   "id_transaction"
	    t.integer  "amount"
	    t.integer  "payment_status"
	    t.string   "moip_code"
	    t.integer  "payment_method"
	    t.string   "payment_type"
	    t.integer  "installments"
	    t.integer  "user_id"
	  end  	
  end
end
