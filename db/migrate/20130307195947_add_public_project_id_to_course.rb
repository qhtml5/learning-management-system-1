class AddPublicProjectIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :wistia_public_project_id, :string
    add_column :courses, :wistia_project_id, :string
  end
end
