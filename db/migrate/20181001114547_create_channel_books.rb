class CreateChannelBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :channel_books do |t|
      t.references :channel, foreign_key: true
      t.references :book, foreign_key: true
      t.integer :index, null: false
      t.integer :status, null: false, default: 1, comment: "1:waiting, 2:delivering, 3:finished"
      t.text :comment

      t.timestamps
    end
    add_index :channel_books, :index
    add_index :channel_books, :status
    add_index :channel_books, [:channel_id, :book_id], unique: true
    add_index :channel_books, [:channel_id, :index], unique: true
  end
end
