class AddPrivateToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :personal, :boolean, default: false
  end
end
