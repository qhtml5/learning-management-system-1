class RemoveOverviewToCourse < ActiveRecord::Migration
  def up
    remove_column :courses, :overview
  end

  def down
    add_column :courses, :overview, :text
  end
end
