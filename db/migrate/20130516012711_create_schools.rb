class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name
      t.text :about_us
      t.references :user
      t.string :site
      t.string :twitter
      t.string :facebook
      t.string :moip_login
      t.string :domain
      t.string :slug
      t.string :subdomain

      t.timestamps
    end
    add_index :schools, :user_id
  end
end
