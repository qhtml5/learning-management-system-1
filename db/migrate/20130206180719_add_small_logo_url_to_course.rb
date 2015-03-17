class AddSmallLogoUrlToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :small_logo_url, :string
  end
end
