class CreateCourseEvaluations < ActiveRecord::Migration
  def change
    create_table :course_evaluations do |t|
      t.text :comment
      t.decimal :score
      t.references :user
      t.references :course

      t.timestamps
    end
    add_index :course_evaluations, :user_id
    add_index :course_evaluations, :course_id
  end
end
