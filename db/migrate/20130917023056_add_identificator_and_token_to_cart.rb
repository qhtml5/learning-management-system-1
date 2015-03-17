class AddIdentificatorAndTokenToCart < ActiveRecord::Migration
  def change
    add_column :carts, :identificator, :string
    add_column :carts, :token, :string
  end
end
