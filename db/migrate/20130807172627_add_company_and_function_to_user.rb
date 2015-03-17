class AddCompanyAndFunctionToUser < ActiveRecord::Migration
  def change
    add_column :users, :company, :string
    add_column :users, :function, :string
  end
end
