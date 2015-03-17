class DropTablesRelantionship < ActiveRecord::Migration
  def up
  	drop_table :courses_relationships
  	drop_table :media_relationships
  end

  def down
	  create_table "courses_relationships" do |t|
	    t.integer  "course_id"
	    t.integer  "relationship_id"
	    t.datetime "created_at",      :null => false
	    t.datetime "updated_at",      :null => false
	  end

    create_table "media_relationships" do |t|
	    t.integer  "relationship_id"
	    t.integer  "media_id"
	    t.datetime "created_at",      :null => false
	    t.datetime "updated_at",      :null => false
	  end
  end
end
