class CreateChannelBooks < ActiveRecord::Migration[5.2]
  def up
    create_table :channel_books do |t|
      t.references :channel, foreign_key: true, null: false
      t.references :book, foreign_key: true, null: false
      t.integer :index, null: false

      t.timestamps
    end
    add_index :channel_books, :index
    add_index :channel_books, [:channel_id, :book_id], unique: true

    # channel_idとindexでユニークにしつつ、並べ替えできるようにdeferredにする
    execute "ALTER TABLE channel_books ADD CONSTRAINT index_channel_books_on_channel_id_and_index UNIQUE (channel_id, index) DEFERRABLE INITIALLY DEFERRED;"
  end

  def down
    drop_table :channel_books
  end
end
