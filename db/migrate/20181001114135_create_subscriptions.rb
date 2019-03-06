class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def up
    create_table :subscriptions, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.references :channel, type: :uuid, foreign_key: true, null: false
      t.references :current_book, foreign_key: { to_table: :books }
      t.integer :next_chapter_index
      t.integer :delivery_hour, default: 8, null: false
      t.date :next_delivery_date
      t.text :footer

      t.timestamps
    end
    add_index :subscriptions, [:user_id, :channel_id], unique: true

    # current_book_idとnext_chapter_indexが、片方だけ入らないようにする
    execute "ALTER TABLE subscriptions ADD CONSTRAINT next_chapter_constraint CHECK ((current_book_id IS NULL AND next_chapter_index IS NULL) OR (current_book_id IS NOT NULL AND next_chapter_index IS NOT NULL));"
    # next_delivery_dateがあるのにcurrent_book_idがない状態を防ぐ（一時停止中など、逆はありえる）
    execute "ALTER TABLE subscriptions ADD CONSTRAINT next_delivery_constraint CHECK (current_book_id IS NOT NULL OR next_delivery_date IS NULL);"
  end

  def down
    drop_table :subscriptions
  end
end
