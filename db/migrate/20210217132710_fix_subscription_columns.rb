class FixSubscriptionColumns < ActiveRecord::Migration[6.0]
  def change
    remove_column :subscriptions, :paused, :boolean, default: false, null: false
    add_column :subscriptions, :status, :string, null: false
    add_index :subscriptions, :status

    add_column :subscription_logs, :status, :string, null: false
    add_index :subscription_logs, :status
  end
end
