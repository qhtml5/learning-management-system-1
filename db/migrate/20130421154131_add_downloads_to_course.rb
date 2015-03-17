class AddDownloadsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :downloads, :text
  end
end
