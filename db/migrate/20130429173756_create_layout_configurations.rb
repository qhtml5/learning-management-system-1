class CreateLayoutConfigurations < ActiveRecord::Migration
  def change
    create_table :layout_configurations do |t|
      t.string :background
      t.string :menu_bar
      t.string :box_header
      t.integer :user_id
      t.timestamps

      t.attachment :site_logo
    end
  end
end
