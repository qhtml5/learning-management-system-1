class AddCourseIdToLead < ActiveRecord::Migration
  def change
    add_column :leads, :course_id, :integer
  end
end
