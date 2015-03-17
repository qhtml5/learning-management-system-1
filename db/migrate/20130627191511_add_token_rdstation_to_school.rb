class AddTokenRdstationToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :token_rdstation, :string
  end
end
