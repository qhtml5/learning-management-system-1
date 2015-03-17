class RenameColumnTypeInMedia < ActiveRecord::Migration
  def up
  	rename_column :medias, :type, :kind
  end

  def down
  	rename_column :medias, :kind, :type
  end
end
