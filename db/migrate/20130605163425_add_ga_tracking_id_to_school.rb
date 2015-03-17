class AddGaTrackingIdToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :ga_tracking_id, :string
  end
end
