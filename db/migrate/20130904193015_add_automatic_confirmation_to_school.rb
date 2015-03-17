class AddAutomaticConfirmationToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :automatic_confirmation, :boolean, default: false
  end
end
