class AddSchoolIdToCourse < ActiveRecord::Migration
  def up
    rename_column :courses, :tenant_id, :school_id
    rename_column :users, :tenant_id, :school_id
    rename_column :carts, :tenant_id, :school_id
    rename_column :purchases, :tenant_id, :school_id
    remove_column :cart_items, :tenant_id
  end

  def down
  	rename_column :courses, :school_id, :tenant_id
    rename_column :users, :school_id, :tenant_id
    rename_column :carts, :school_id, :tenant_id
    rename_column :purchases, :school_id, :tenant_id
    add_column :cart_items, :tenant_id, :intger
  end
end
