class CreateLessonsMedias < ActiveRecord::Migration
  def up
  	drop_table :courses_medias

		create_table :lessons_medias do |t|
			t.integer :lesson_id
			t.integer :media_id
			t.integer :sequence
			t.string :title
			t.timestamps
		end
  end

  def down
  	drop_table :lessons_medias

  	create_table "courses_medias" do |t|
	    t.integer "course_id"
	    t.integer "media_id"
	    t.integer "sequence"
	  end
  end
end
