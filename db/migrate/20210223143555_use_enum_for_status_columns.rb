class UseEnumForStatusColumns < ActiveRecord::Migration[6.0]
  def up
    change_column :memberships, :status, :integer, default: 1, using: 'status::integer'
    change_column :membership_logs, :status, :integer, default: 1, using: 'status::integer'
    change_column :subscriptions, :status, :integer, default: 1, using: 'status::integer'
    change_column :subscription_logs, :status, :integer, default: 1, using: 'status::integer'
  end

  def down
    change_column :memberships, :status, :string
    change_column :membership_logs, :status, :string
    change_column :subscriptions, :status, :string
    change_column :subscription_logs, :status, :string
  end
end
