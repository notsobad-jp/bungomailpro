class CreateChannelBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :channel_books do |t|
      t.references :channel, foreign_key: true, null: false
      t.references :book, foreign_key: true, null: false
      t.integer :index
      t.boolean :delivered, default: false, null: false
      t.text :comment

      t.timestamps
    end
    add_index :channel_books, :index
    add_index :channel_books, :delivered
    add_index :channel_books, [:channel_id, :book_id], unique: true
  end
end
