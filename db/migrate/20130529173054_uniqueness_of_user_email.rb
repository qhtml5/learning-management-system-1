class UniquenessOfUserEmail < ActiveRecord::Migration
  def up
  	remove_index :users, :name => "index_usuarios_on_email"
  	add_index :users, :email
  end

  def down
  	add_index :users, :email, :name => "index_usuarios_on_email"
  	remove_index :users, :email
  end
end
