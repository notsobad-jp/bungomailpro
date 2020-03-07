class AddScheduledAtToFeed < ActiveRecord::Migration[5.2]
  def change
    add_column :feeds, :scheduled_at, :datetime
    add_index :feeds, :scheduled_at
  end
end
