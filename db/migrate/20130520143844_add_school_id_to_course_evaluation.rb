class AddSchoolIdToCourseEvaluation < ActiveRecord::Migration
  def change
    add_column :course_evaluations, :school_id, :integer
  end
end
