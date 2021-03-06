class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :number
      t.string :complement
      t.string :city
      t.string :state
      t.string :zip_code
      t.integer :user_id

      t.timestamps
    end
  end
end
