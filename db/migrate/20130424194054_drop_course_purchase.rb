class DropCoursePurchase < ActiveRecord::Migration
  def up
  	drop_table :courses_purchases
  end

  def down
	  create_table "courses_purchases" do |t|
	    t.integer  "course_id"
	    t.integer  "purchase_id"
	    t.datetime "created_at",  :null => false
	    t.datetime "updated_at",  :null => false
	    t.integer  "coupon_id"
	  end
  end
end
