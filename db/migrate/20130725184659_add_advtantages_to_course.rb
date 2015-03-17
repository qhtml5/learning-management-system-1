class AddAdvtantagesToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :advantages, :text
  end
end
