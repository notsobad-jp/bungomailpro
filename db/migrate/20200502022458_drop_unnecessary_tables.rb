class DropUnnecessaryTables < ActiveRecord::Migration[6.0]
  def up
    drop_table :notifications
    drop_table :feeds
    drop_table :search_conditions
    drop_table :book_assignments
    drop_table :subscriptions
    drop_table :channels
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
