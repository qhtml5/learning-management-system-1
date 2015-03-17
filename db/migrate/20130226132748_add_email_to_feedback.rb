class AddEmailToFeedback < ActiveRecord::Migration
  def change
  	add_column :feedbacks, :email, :string, :limit => 100
  end
end
