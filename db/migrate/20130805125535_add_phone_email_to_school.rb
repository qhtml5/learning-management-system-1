class AddPhoneEmailToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :phone, :string
  	add_column :schools, :email, :string
  end
end
