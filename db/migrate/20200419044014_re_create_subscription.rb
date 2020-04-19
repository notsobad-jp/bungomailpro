class ReCreateSubscription < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.references :channel, type: :uuid, foreign_key: true, null: false
      t.timestamps
    end
    add_index :subscriptions, [:user_id, :channel_id], unique: true
  end
end
