class AddClassificationCodeToPurchase < ActiveRecord::Migration
  def change
  	add_column :purchases, :classification_code, :string
  	rename_column :purchases, :description, :classification_description
  end
end
