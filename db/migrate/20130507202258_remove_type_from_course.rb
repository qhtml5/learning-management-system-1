class RemoveTypeFromCourse < ActiveRecord::Migration
  def up
  	remove_column :courses, :type
  end

  def down
  	add_column :courses, :type, :string
  end
end
