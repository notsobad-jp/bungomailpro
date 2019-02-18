class CreateSubscriptionUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :subscription_users, id: false do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.references :subscription, type: :uuid, foreign_key: true, null: false
      t.timestamps
    end
    add_index :subscription_users, [:user_id, :subscription_id], unique: true
  end
end
