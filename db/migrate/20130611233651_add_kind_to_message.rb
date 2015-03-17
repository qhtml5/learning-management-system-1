class AddKindToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :kind, :integer
  end
end
