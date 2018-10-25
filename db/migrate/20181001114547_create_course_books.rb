class CreateCourseBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :course_books do |t|
      t.references :course, foreign_key: true
      t.references :book, foreign_key: true
      t.integer :index, null: false

      t.timestamps
    end
    add_index :course_books, :index
  end
end
