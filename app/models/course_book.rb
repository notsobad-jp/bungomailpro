# == Schema Information
#
# Table name: course_books
#
#  id         :bigint(8)        not null, primary key
#  course_id  :bigint(8)
#  book_id    :bigint(8)
#  index      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CourseBook < ApplicationRecord
  belongs_to :course
  belongs_to :book
end
