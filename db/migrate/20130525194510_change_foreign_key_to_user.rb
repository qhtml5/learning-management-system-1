class ChangeForeignKeyToUser < ActiveRecord::Migration
  def up
  	remove_column :schools, :tenant_id
  	remove_column :schools, :user_id
  end

  def down
  	add_column :schools, :tenant_id, :integer
  	add_column :schools, :user_id, :integer
  end
end
