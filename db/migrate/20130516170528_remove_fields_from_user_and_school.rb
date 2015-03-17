class RemoveFieldsFromUserAndSchool < ActiveRecord::Migration
  def up
  	remove_column :schools, :status

  	remove_column :users, :domain
  	remove_column :users, :username
  	remove_column :users, :moip_login
  	remove_column :users, :wistia_public_project_id

  	add_column :schools, :wistia_public_project_id, :string
  end

  def down
  	add_column :schools, :status, :string

  	add_column :users, :domain, :string
  	add_column :users, :username, :string
  	add_column :users, :moip_login, :string
  	add_column :users, :wistia_public_project_id, :string

  	remove_column :schools, :wistia_public_project_id
  end
end
