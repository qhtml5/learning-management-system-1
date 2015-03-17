class CreateMessageAnswers < ActiveRecord::Migration
  def change
    create_table :messages_answers do |t|
      t.integer :message_id
      t.integer :answer_id

      t.timestamps
    end
  end
end
