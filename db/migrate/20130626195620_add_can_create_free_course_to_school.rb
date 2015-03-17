class AddCanCreateFreeCourseToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :can_create_free_course, :boolean, default: false
  end
end
