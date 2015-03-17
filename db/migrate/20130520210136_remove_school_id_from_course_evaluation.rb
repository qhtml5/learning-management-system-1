class RemoveSchoolIdFromCourseEvaluation < ActiveRecord::Migration
  def up
    remove_column :course_evaluations, :school_id
  end

  def down
    add_column :course_evaluations, :school_id, :string
  end
end
