class AddDefaultPlanToSchool < ActiveRecord::Migration
  def change
  	change_column :schools, :plan, :string, default: "trial"
  end
end
