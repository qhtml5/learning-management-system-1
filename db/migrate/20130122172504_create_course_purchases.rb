class CreateCoursePurchases < ActiveRecord::Migration
  def up
    create_table :courses_purchases do |t|
    	t.integer :course_id
    	t.integer :purchase_id
      t.timestamps
    end
    remove_column :courses, :purchase_id
  end

  def down
  	drop_table :courses_purchases
  	add_column :courses, :purchase_id, :integer
  end
end
