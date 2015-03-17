class AddWhoShouldAttendToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :who_should_attend, :text
  end
end
