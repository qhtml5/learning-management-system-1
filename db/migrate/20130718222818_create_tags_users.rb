class CreateTagsUsers < ActiveRecord::Migration
  def up
  	create_table :tags_users do |t|
  		t.integer :user_id
  		t.integer :tag_id

  		t.timestamps
  	end
  end

  def down
  	drop_table :tags_users
  end
end
