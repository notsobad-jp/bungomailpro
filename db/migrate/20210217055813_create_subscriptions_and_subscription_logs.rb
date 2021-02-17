class CreateSubscriptionsAndSubscriptionLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, null: false
      t.references :channel, type: :uuid, null: false
      t.boolean :paused, default: :false, null: false
      t.timestamps
    end
    add_index :subscriptions, [:user_id, :channel_id], unique: true
    add_foreign_key :subscriptions, :users, on_delete: :cascade
    add_foreign_key :subscriptions, :channels, on_delete: :cascade

    create_table :subscription_logs, id: :uuid do |t|
      t.references :user, type: :uuid, null: false
      t.references :channel, type: :uuid, null: false
      t.references :membership_log, type: :uuid, foreign_key: true
      t.string :action, null: false, index: true
      t.datetime :apply_at, null: false, index: true, default: -> { 'CURRENT_TIMESTAMP' }
      t.boolean :finished, default: false, null: false
      t.boolean :canceled, default: false, null: false
      t.timestamps
    end
    add_index :subscription_logs, [:user_id, :channel_id]
    add_foreign_key :subscription_logs, :users, on_delete: :cascade
    add_foreign_key :subscription_logs, :channels, on_delete: :cascade
  end
end
