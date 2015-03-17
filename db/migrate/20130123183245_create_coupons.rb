class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.integer :percentage
      t.string :name

      t.timestamps
    end
  end
end
