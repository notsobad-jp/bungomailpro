class AddCanonicalBookIdToAozoraBook < ActiveRecord::Migration[6.0]
  def change
    add_column :aozora_books, :canonical_book_id, :integer
    add_index :aozora_books, :canonical_book_id
  end
end
