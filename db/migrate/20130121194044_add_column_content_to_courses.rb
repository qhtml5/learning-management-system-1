class AddColumnContentToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :content, :text
  end
end
