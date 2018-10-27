# == Schema Information
#
# Table name: courses
#
#  id          :bigint(8)        not null, primary key
#  title       :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Course < ApplicationRecord
  has_many :user_courses
  has_many :users, through: :user_courses
  has_many :course_books
  has_many :books, through: :course_books
  accepts_nested_attributes_for :course_books, allow_destroy: true

  def first_book_id
    self.course_books.order(index: :asc).first.book_id
  end

  def next_book_id(current_id)
    current_index = self.course_books.find_by(book_id: current_id).index
    self.course_books.find_by(index: current_index + 1)
  end
end
