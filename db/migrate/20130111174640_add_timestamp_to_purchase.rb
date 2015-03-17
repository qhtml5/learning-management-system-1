class AddTimestampToPurchase < ActiveRecord::Migration
  def up
  	change_table :purchases do |t|
  		t.timestamps
  	end
  end

  def down
  	remove_column :purchases, :created_at
  	remove_column :purchases, :updated_at
  end
end
