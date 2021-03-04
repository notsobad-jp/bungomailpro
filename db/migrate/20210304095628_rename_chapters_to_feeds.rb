class RenameChaptersToFeeds < ActiveRecord::Migration[6.0]
  def change
    rename_table :chapters, :feeds
  end
end
