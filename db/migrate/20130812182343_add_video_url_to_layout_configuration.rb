class AddVideoUrlToLayoutConfiguration < ActiveRecord::Migration
  def change
    add_column :layout_configurations, :video_url, :string
  end
end
