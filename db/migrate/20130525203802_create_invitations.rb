class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :role
      t.integer :school_id

      t.timestamps
    end
  end
end
