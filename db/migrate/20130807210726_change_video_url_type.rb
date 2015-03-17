class ChangeVideoUrlType < ActiveRecord::Migration
  def change
    change_column :courses, :video_url, :string
  end
end
