class PassLayoutConfigurationFromUserToSchool < ActiveRecord::Migration
  def up
  	remove_column :layout_configurations, :user_id
  	add_column :layout_configurations, :school_id, :integer
  end

  def down
  	add_column :layout_configurations, :user_id, :integer
  	remove_column :layout_configurations, :school_id
  end
end
