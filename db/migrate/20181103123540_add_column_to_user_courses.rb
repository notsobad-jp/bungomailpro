class AddColumnToUserCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :user_courses, :next_book_index, :integer, null: false, default: 1
  end
end
