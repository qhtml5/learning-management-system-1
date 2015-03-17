class CreateCourseCategories < ActiveRecord::Migration
  def change
    create_table :course_categories do |t|
      t.string :name
      t.integer :school_id
      t.integer :sequence

      t.timestamps
    end

    add_column :courses, :course_category_id, :integer
  end
end
