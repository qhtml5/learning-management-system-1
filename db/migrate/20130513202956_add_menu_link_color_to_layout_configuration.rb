class AddMenuLinkColorToLayoutConfiguration < ActiveRecord::Migration
  def change
    add_column :layout_configurations, :menu_link_color, :string
  end
end
