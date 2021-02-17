class RenameSubscriptionLogsToChannelSubscriptionLogs < ActiveRecord::Migration[6.0]
  def change
    rename_table :subscription_logs, :channel_subscription_logs
  end
end
