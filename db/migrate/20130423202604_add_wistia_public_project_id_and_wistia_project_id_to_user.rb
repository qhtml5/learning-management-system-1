class AddWistiaPublicProjectIdAndWistiaProjectIdToUser < ActiveRecord::Migration
  def up
    add_column :users, :wistia_public_project_id, :string
    remove_column :courses, :wistia_public_project_id
    remove_column :courses, :wistia_project_id
  end

  def down
  	remove_column :users, :wistia_public_project_id
  	add_column :courses, :wistia_project_id, :string
  	add_column :courses, :wistia_public_project_id, :string
  end
end
