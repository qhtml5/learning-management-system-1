class CreateCourseUsers < ActiveRecord::Migration
  def change
    create_table :courses_users do |t|
    	t.integer :teacher_id
    	t.integer :student_id
    	t.integer :course_id
      t.timestamps
    end
  end
end
