class RenameRolesMaskToRoleUser < ActiveRecord::Migration
  def up
  	remove_column :users, :roles_mask
  	add_column :users, :role, :string
  end

  def down
    remove_column :users, :role
    add_column :users, :roles_mask, :integer
  end
end
