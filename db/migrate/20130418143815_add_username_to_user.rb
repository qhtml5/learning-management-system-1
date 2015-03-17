class AddUsernameToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :slug, :string
  end
end
