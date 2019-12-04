class CreateGutenBooksSubjects < ActiveRecord::Migration[5.2]
  def change
    create_table :guten_books_subjects, id: false do |t|
      t.references :guten_book, foreign_key: true
      t.references :subject, type: :string, foreign_key: true
    end
    add_index :guten_books_subjects, [:guten_book_id, :subject_id], unique: true
  end
end
