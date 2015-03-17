class AddContentAndGoalsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :content_and_goals, :text
  end
end
