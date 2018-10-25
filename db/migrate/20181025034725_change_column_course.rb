class ChangeColumnCourse < ActiveRecord::Migration[5.2]
  def change
    change_column :courses, :title, :string, null: false
    change_column :books, :title, :string, null: false
    change_column :course_books, :index, :integer, null: false
    change_column :chapters, :index, :integer, null: false
  end
end
