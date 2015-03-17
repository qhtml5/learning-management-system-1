class DropTagAndTagUser < ActiveRecord::Migration
  def up
  	drop_table :tags
  	drop_table :tags_users
  end

  def down
  	create_table "tags" do |t|
	    t.integer  "school_id"
	    t.string   "name"
	    t.datetime "created_at", :null => false
	    t.datetime "updated_at", :null => false
	  end

	  create_table "tags_users" do |t|
	    t.integer  "user_id"
	    t.integer  "tag_id"
	    t.datetime "created_at", :null => false
	    t.datetime "updated_at", :null => false
	  end
  end
end
