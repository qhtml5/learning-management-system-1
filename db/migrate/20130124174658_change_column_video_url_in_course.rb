class ChangeColumnVideoUrlInCourse < ActiveRecord::Migration
  def up
  	change_column :courses, :video_url, :text
  end

  def down
  	change_column :courses, :video_url, :string
  end
end
