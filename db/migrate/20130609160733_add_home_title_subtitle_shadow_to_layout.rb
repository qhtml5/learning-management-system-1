class AddHomeTitleSubtitleShadowToLayout < ActiveRecord::Migration
  def change
    add_column :layout_configurations, :home_title_subtitle_shadow, :string
  end
end
