class ChangeUserEmailIndex < ActiveRecord::Migration
	def up
	  remove_index :users, :email
	  add_index :users, [:email, :school_id], :unique => true
	end

	def down
	  remove_index :users, [:email, :school_id]
		add_index :users, :email, unique: true
	end
end
