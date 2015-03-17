class AddPlanToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :plan, :string
  end
end
