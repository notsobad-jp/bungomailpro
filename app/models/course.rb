# == Schema Information
#
# Table name: courses
#
#  id          :bigint(8)        not null, primary key
#  title       :string           not null
#  description :text
#  owner_id    :bigint(8)        not null
#  status      :integer          default(1), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Course < ApplicationRecord
  has_many :subscriptions
  has_many :users, through: :subscriptions
  has_many :course_books, -> { order(:index) }
  has_many :books, through: :course_books
  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  accepts_nested_attributes_for :course_books, allow_destroy: true

  validates :title, presence: true
  validates :course_books, presence: true
  validates :status, inclusion: { in: [1,2,3] }


  def first_book_id
    self.course_books.order(index: :asc).first.book_id
  end

  def next_book_id(current_id)
    current_index = self.course_books.find_by(book_id: current_id).index
    self.course_books.find_by(index: current_index + 1)
  end

  def draft?
    self.status == 1
  end

  def public?
    self.status == 2
  end

  def closed?
    self.status == 3
  end
end
