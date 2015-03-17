class AddItensToLayout < ActiveRecord::Migration
  def change
    add_column :layout_configurations, :menu_link_hover_color, :string
    add_column :layout_configurations, :box_header_color, :string
    add_column :layout_configurations, :box_content, :string
    add_column :layout_configurations, :box_content_color, :string
    add_column :layout_configurations, :title_home_color, :string
  end
end
