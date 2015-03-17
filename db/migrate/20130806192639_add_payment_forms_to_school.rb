class AddPaymentFormsToSchool < ActiveRecord::Migration
  def change
  	add_column :schools, :accept_credit_card, :boolean, default: true
  	add_column :schools, :accept_online_debit, :boolean, default: true
  	add_column :schools, :accept_billet, :boolean, default: true
  end
end
