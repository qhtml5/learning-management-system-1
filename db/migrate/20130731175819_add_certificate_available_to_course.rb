class AddCertificateAvailableToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :certificate_available, :boolean, default: false
  end
end
