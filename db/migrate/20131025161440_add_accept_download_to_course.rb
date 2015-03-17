class AddAcceptDownloadToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :accept_download, :boolean, default: false
  end
end
