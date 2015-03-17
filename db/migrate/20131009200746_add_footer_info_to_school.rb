class AddFooterInfoToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :footer_info, :text
  end
end
