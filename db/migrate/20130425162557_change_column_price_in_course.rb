class ChangeColumnPriceInCourse < ActiveRecord::Migration
  def up
  	change_column :courses, :price, :integer, default: 0, null: false
  end

  def down
  	change_column :courses, :price, :integer
  end
end
