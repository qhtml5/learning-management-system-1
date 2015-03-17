class AddUseCustomDomainToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :use_custom_domain, :boolean, default: false
  end
end
