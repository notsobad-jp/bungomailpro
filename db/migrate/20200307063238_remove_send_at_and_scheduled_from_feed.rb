class RemoveSendAtAndScheduledFromFeed < ActiveRecord::Migration[5.2]
  def change
    remove_column :feeds, :send_at, :date
    remove_column :feeds, :scheduled, :boolean, default: false
  end
end
