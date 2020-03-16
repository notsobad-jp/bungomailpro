class ChangeBooksToAozoraBooks < ActiveRecord::Migration[6.0]
  def change
    rename_table :books, :aozora_books
  end
end
