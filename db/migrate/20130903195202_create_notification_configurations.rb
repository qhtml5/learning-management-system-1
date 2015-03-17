class CreateNotificationConfigurations < ActiveRecord::Migration
  def change
    create_table :notification_configurations do |t|
      t.boolean :user_new_registration, default: true
      t.boolean :user_new_contact, default: true
      t.boolean :course_new_question, default: true
      t.boolean :course_add_to_cart, default: true
      t.boolean :course_new_evaluation, default: true
      t.boolean :course_new_certificate_request, default: true
      t.boolean :purchase_pending, default: true
      t.boolean :purchase_confirmed, default: true
      t.integer :school_id
      t.timestamps
    end
  end
end
