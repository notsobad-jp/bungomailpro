class RefactorSubscription < ActiveRecord::Migration[6.0]
  def up
    drop_table :subscription_logs
    remove_column :subscriptions, :status
    add_column :subscriptions, :paused, :boolean, null: false, default: false
  end

  def down
    create_table :subscription_logs, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :channel, type: :uuid, null: false, foreign_key: true
      t.references :membership_log, type: :uuid, foreign_key: true
      t.datetime :apply_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.boolean :finished, null: false, default: false
      t.boolean :canceled, null: false, default: false
      t.integer :status, null: false, default: 1
      t.string :google_action
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :updated_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
    add_column :subscriptions, :status, :integer, null: false, default: 1
    remove_column :subscriptions, :paused
  end
end
