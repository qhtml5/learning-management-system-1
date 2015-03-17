class AddSchoolIdToLead < ActiveRecord::Migration
  def change
    add_column :leads, :school_id, :integer
  end
end
