class FixForeignKeyCascade < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :book_assignments, :channels
    add_foreign_key :book_assignments, :channels, on_delete: :cascade

    remove_foreign_key :channel_profiles, :channels, column: :id
    add_foreign_key :channel_profiles, :channels, column: :id, on_delete: :cascade

    remove_foreign_key :chapters, :book_assignments
    add_foreign_key :chapters, :book_assignments, on_delete: :cascade

    remove_foreign_key :guten_books_subjects, :subjects
    add_foreign_key :guten_books_subjects, :subjects, on_delete: :cascade

    add_foreign_key :guten_books_subjects, :guten_books, on_delete: :cascade
  end
end
