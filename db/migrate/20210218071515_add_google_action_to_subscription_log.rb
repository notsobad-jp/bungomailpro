class AddGoogleActionToSubscriptionLog < ActiveRecord::Migration[6.0]
  def change
    add_column :subscription_logs, :google_action, :string
  end
end
