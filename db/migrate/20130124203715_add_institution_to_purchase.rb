class AddInstitutionToPurchase < ActiveRecord::Migration
  def change
    add_column :purchases, :institution, :string
  end
end
