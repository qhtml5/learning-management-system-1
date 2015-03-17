class CourseDefaultStatus < ActiveRecord::Migration
  def up
  	change_column :courses, :status, :string, default: Course::DRAFT
  end

  def down
  	change_column :courses, :status, :string
  end
end
