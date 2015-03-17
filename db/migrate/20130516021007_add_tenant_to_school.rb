class AddTenantToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :tenant_id, :integer
  end
end
