class AddIdentificatorToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :identificator, :string
  end
end
