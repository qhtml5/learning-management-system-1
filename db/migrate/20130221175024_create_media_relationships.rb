class CreateMediaRelationships < ActiveRecord::Migration
  def change
    create_table :media_relationships do |t|
      t.integer :relationship_id
      t.integer :media_id

      t.timestamps
    end
  end
end
