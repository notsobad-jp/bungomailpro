class ChangeAssignedBooksToBookAssignments < ActiveRecord::Migration[5.2]
  def change
    rename_table :assigned_books, :book_assignments
    rename_column :feeds, :assigned_book_id, :book_assignment_id
  end
end
