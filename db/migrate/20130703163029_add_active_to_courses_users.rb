class AddActiveToCoursesUsers < ActiveRecord::Migration
  def change
    add_column :courses_users, :within_validity, :boolean, default: true
  end
end
