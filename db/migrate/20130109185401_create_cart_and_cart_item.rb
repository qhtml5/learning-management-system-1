class CreateCartAndCartItem < ActiveRecord::Migration
  def change
  	create_table :carts do |t|
  		t.timestamps
  	end

  	create_table :cart_items do |t|
  		t.integer :cart_id
  		t.integer :course_id
  		t.timestamps
  	end
  end
end
