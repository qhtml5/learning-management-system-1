class AddColumnPurchaseIdToCourses < ActiveRecord::Migration
  def change
  	add_column :courses, :purchase_id, :integer
  end
end
