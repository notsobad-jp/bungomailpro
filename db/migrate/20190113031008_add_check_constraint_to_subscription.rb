class AddCheckConstraintToSubscription < ActiveRecord::Migration[5.2]
  def up
    # current_book_idとnext_chapter_indexが、片方だけ入らないようにする
    execute "ALTER TABLE subscriptions ADD CONSTRAINT next_chapter_constraint CHECK ((current_book_id IS NULL AND next_chapter_index IS NULL) OR (current_book_id IS NOT NULL AND next_chapter_index IS NOT NULL));"
    # next_delivery_dateがあるのにcurrent_book_idがない状態を防ぐ（一時停止中など、逆はありえる）
    execute "ALTER TABLE subscriptions ADD CONSTRAINT next_delivery_constraint CHECK (current_book_id IS NOT NULL OR next_delivery_date IS NULL);"
  end

  def down
    execute "ALTER TABLE subscriptions DROP CONSTRAINT next_chapter_constraint"
    execute "ALTER TABLE subscriptions DROP CONSTRAINT next_delivery_constraint"
  end
end
