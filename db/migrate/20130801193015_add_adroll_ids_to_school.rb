class AddAdrollIdsToSchool < ActiveRecord::Migration
  def change
  	add_column :schools, :adroll_adv_id, :string
  	add_column :schools, :adroll_pix_id, :string
  end
end
