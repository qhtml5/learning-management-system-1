class CreateTableCoursesMedias < ActiveRecord::Migration
  def up
  	create_table :courses_medias do |t|
  		t.integer :course_id
  		t.integer :media_id
  		t.integer :order
  	end
  end

  def down
  	drop_table :courses_medias
  end
end
