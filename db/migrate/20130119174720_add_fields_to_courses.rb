class AddFieldsToCourses < ActiveRecord::Migration
  def up
  	add_column :courses, :pitch, :string
  	add_column :courses, :logo_url, :string
  	add_column :courses, :video_url, :string
  	add_column :courses, :video_title, :string
  	add_column :courses, :video_subtitle, :string
  	add_column :courses, :last_call_to_action, :string
  end

  def down
  	remover_column :courses, :pitch
  	remover_column :courses, :logo_url
  	remover_column :courses, :video_url
  	remover_column :courses, :video_title
  	remover_column :courses, :video_subtitle
  	remover_column :courses, :last_call_to_action
  end
end
