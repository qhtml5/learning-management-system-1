class ChangeColumnVideoUrlFromCourse < ActiveRecord::Migration
  def up
  	change_column :courses, :video_url, :string
  	remove_column :courses, :wistia_promo_video_id
  end

  def down
  	change_column :courses, :video_url, :text
  	add_column :courses, :wistia_promo_video_id, :string
  end
end
