class AddEmailFlagsToUser < ActiveRecord::Migration
  def change
    add_column :users, :sent_new_purchase_email, :boolean, :default => false
    add_column :users, :sent_purchase_confirmation_email, :boolean, :default => false
  end
end
