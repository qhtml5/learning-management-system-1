class AddWistiaHashedIdToMedia < ActiveRecord::Migration
  def change
    add_column :medias, :wistia_hashed_id, :string
  end
end
