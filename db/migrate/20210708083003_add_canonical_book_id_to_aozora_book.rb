class AddCanonicalBookIdToAozoraBook < ActiveRecord::Migration[6.0]
  def up
    add_column :aozora_books, :canonical_book_id, :integer, index: true
    add_index :aozora_books, :canonical_book_id
    add_foreign_key :aozora_books, :aozora_books, column: :canonical_book_id
  end

  def down
    remove_column :aozora_books, :canonical_book_id
  end
end
