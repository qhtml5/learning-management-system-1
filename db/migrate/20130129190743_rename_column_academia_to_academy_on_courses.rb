class RenameColumnAcademiaToAcademyOnCourses < ActiveRecord::Migration
  def up
  	rename_column :courses, :academia, :academy
  end

  def down
  	rename_column :courses, :academy, :academia
  end
end
