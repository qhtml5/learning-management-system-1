class AddIntroductionInfoToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :introduction_info, :text
  end
end
