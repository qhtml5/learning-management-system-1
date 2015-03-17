class AddMainColorPageTitleHomeTitleHomeSubtitleHomeLogoToLayoutConfiguration < ActiveRecord::Migration
  def change
    add_column :layout_configurations, :main_color, :string
    add_column :layout_configurations, :title, :string
    add_column :layout_configurations, :home_title, :string
    add_column :layout_configurations, :home_subtitle, :string
    
    add_attachment :layout_configurations, :home_logo
  end
end
