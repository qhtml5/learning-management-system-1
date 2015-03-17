class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.boolean :like
      t.text :text

      t.timestamps
    end
  end
end
