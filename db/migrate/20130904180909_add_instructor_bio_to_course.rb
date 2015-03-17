class AddInstructorBioToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :instructor_bio, :text
  end
end
