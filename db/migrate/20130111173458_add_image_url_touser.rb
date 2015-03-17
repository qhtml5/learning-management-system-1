class AddImageUrlTouser < ActiveRecord::Migration
  def up
  	add_column :users, :image_url, :string
  end

  def down
  	remover_column :users, :image_url
  end
end
