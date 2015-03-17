class CreateCourseRelationships < ActiveRecord::Migration
  def change
    create_table :courses_relationships do |t|
      t.integer :course_id
      t.integer :relationship_id

      t.timestamps
    end
  end
end
