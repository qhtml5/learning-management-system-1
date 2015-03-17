class CreateMedias < ActiveRecord::Migration
  def change
    create_table :medias do |t|
      t.string :title
      t.string :url
      t.text :text
      t.string :type

      t.timestamps
    end
  end
end
