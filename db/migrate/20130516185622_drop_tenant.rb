class DropTenant < ActiveRecord::Migration
  def up
  	drop_table :tenants
  end

  def down
	  create_table "tenants" do |t|
	    t.string   "name"
	    t.string   "subdomain"
	    t.datetime "created_at", :null => false
	    t.datetime "updated_at", :null => false
	  end
  end
end
