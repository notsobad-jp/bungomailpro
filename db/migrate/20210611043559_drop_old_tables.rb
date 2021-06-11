class DropOldTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :memberships
    drop_table :membership_logs
    add_column :users, :stripe_customer_id, :string
  end
end
