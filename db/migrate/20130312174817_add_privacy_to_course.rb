class AddPrivacyToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :privacy, :string, :default => :public
  end
end
