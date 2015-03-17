class ChangeEmailFlagsFromUserToPurchase < ActiveRecord::Migration
  def up
    remove_column :users, :sent_new_purchase_email
    remove_column :users, :sent_purchase_confirmation_email

    add_column :purchases, :sent_new_email, :boolean, :default => false
    add_column :purchases, :sent_confirmation_email, :boolean, :default => false
  end

  def down
    add_column :users, :sent_new_purchase_email, :boolean, :default => false
    add_column :users, :sent_purchase_confirmation_email, :boolean, :default => false

    remove_column :purchases, :sent_new_email
    remove_column :purchases, :sent_confirmation_email
  end
end
