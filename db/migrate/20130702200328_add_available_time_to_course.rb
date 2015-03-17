class AddAvailableTimeToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :available_time, :integer, default: 0
  end
end
