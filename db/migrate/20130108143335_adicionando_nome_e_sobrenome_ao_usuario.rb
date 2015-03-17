class AdicionandoNomeESobrenomeAoUsuario < ActiveRecord::Migration
  def up
  	add_column :usuarios, :nome, :string, :limit => 40
  	add_column :usuarios, :sobrenome, :string, :limit => 40
  end

  def down
  	remove_column :usuarios, :nome
  	remove_column :usuarios, :sobrenome
  end
end
