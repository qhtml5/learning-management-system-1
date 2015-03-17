class AddColumnsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :skype, :string
  	add_column :users, :telefone, :string
  	add_column :users, :cpf, :string
  end
end
