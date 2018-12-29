class UniqueConstraintOnChannelBookIndex < ActiveRecord::Migration[5.2]
  def up
    execute "ALTER TABLE channel_books ADD CONSTRAINT index_channel_books_on_channel_id_and_index UNIQUE (channel_id, index) DEFERRABLE INITIALLY DEFERRED;"
  end

  def down
    execute "ALTER TABLE channel_books DROP CONSTRAINT index_channel_books_on_channel_id_and_index;"
  end
end
