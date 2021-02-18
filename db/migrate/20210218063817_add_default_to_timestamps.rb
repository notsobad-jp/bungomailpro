class AddDefaultToTimestamps < ActiveRecord::Migration[6.0]
  def up
    change_column :memberships, :created_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
    change_column :memberships, :updated_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
    change_column :subscriptions, :created_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
    change_column :subscriptions, :updated_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
    change_column :subscription_logs, :created_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
    change_column :subscription_logs, :updated_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
  end

  def down
    change_column :memberships, :created_at, :datetime, default: nil
    change_column :memberships, :updated_at, :datetime, default: nil
    change_column :subscriptions, :created_at, :datetime, default: nil
    change_column :subscriptions, :updated_at, :datetime, default: nil
    change_column :subscription_logs, :created_at, :datetime, default: nil
    change_column :subscription_logs, :updated_at, :datetime, default: nil
  end
end
