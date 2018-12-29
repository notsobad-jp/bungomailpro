class PartialUniqueOnDefaultSubscription < ActiveRecord::Migration[5.2]
  def change
    add_index :subscriptions, [:user_id, :default], where: '"default" = true', unique: true
  end
end
