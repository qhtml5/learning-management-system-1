class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :module_configurations do |t|
      t.boolean :remove_edools_logo, default: false
      t.integer :school_id

      t.timestamps
    end

    School.find_each { |s| s.create_module_configuration }
  end
end
