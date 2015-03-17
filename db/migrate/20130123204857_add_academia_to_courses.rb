class AddAcademiaToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :academia, :boolean, :default => false
  end
end
