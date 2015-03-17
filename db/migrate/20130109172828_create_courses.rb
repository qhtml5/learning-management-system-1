class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.string :description
      t.text :overview
      t.integer :price

      t.timestamps
    end
  end
end
