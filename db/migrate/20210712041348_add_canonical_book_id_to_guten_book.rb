class AddCanonicalBookIdToGutenBook < ActiveRecord::Migration[6.0]
  def up
    add_column :guten_books, :canonical_book_id, :integer, index: true
    add_index :guten_books, :canonical_book_id
    add_foreign_key :guten_books, :guten_books, column: :canonical_book_id
    add_column :guten_books, :sub_title, :string
  end

  def down
    remove_column :guten_books, :canonical_book_id
    remove_column :guten_books, :sub_title
  end
end
