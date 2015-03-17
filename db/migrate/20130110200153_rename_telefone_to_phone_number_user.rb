class RenameTelefoneToPhoneNumberUser < ActiveRecord::Migration
  def up
  	rename_column :users, :telefone, :phone_number
  end

  def down
  	rename_column :users, :phone_number, :telefone
  end
end
