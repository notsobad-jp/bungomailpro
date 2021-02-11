class CreateSubscriptionLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_logs, id: :uuid do |t|
      t.string :email, null: false
      t.integer :action, null: false, default: 1
      t.timestamps
      t.index :action
    end
  end
end
