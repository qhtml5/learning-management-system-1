class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :notifiable_id
      t.string :notifiable_type
      t.integer :receiver_id
      t.integer :sender_id

      t.timestamps
    end
  end
end
