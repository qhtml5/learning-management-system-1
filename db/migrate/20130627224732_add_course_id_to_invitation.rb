class AddCourseIdToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :course_id, :integer
  end
end
