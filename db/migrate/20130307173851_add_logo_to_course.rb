class AddLogoToCourse < ActiveRecord::Migration
  def up
  	add_attachment :courses, :logo
  end

  def down
  	remove_attachment :courses, :logo
  end
end
