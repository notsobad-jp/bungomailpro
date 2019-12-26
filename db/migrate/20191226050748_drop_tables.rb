class DropTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :comments
    drop_table :feeds
    drop_table :notifications
    drop_table :subscriptions
    drop_table :channel_books
    drop_table :channels
    drop_table :chapters
  end

  def down
  end
end
