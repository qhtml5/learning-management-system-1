class AddStatusToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :status, :string
  end
end
