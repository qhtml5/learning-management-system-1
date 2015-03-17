class AddTenantToModels < ActiveRecord::Migration
  def change
  	add_column :users, :tenant_id, :integer
  	add_column :courses, :tenant_id, :integer
  	add_column :carts, :tenant_id, :integer
  	add_column :cart_items, :tenant_id, :integer
  	add_column :purchases, :tenant_id, :integer
  end
end
