class AlterTableNotification < ActiveRecord::Migration
  def up
  	add_column :notifications, :code, :integer
  	add_column :notifications, :read, :boolean, default: false
  end

  def down
	  remove_column :notifications, :code
	  remove_column :notifications, :read
  end
end
