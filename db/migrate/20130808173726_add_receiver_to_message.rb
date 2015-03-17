class AddReceiverToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :receiver_id, :integer
  end
end
