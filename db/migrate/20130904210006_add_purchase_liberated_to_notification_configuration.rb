class AddPurchaseLiberatedToNotificationConfiguration < ActiveRecord::Migration
  def change
    add_column :notification_configurations, :purchase_liberated, :boolean
  end
end
