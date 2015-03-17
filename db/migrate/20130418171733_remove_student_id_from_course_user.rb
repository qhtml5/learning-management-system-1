class RemoveStudentIdFromCourseUser < ActiveRecord::Migration
  def up
  	remove_column :courses_users, :student_id
  	rename_column :courses_users, :teacher_id, :user_id
  end

  def down
  	add_column :courses_users, :student_id, :integer
  	rename_column :courses_users, :user_id, :teacher_id
  end
end
