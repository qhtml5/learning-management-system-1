class AddConfirmedAtToCartItem < ActiveRecord::Migration
  def up
    add_column :cart_items, :confirmed_at, :datetime
    remove_column :cart_items, :within_validity
    remove_column :courses_users, :within_validity
  end

  def down
  	remove_column :cart_items, :confirmed_at
  	add_column :cart_items, :within_validity, :boolean
    add_column :courses_users, :within_validity, :boolean
  end
end
