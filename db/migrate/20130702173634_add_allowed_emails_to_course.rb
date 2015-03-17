class AddAllowedEmailsToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :allowed_emails, :text
  end
end
