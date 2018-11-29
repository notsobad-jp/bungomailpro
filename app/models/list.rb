# == Schema Information
#
# Table name: lists
#
#  id          :bigint(8)        not null, primary key
#  user_id     :bigint(8)        not null
#  title       :string           not null
#  description :text
#  published   :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class List < ApplicationRecord
  belongs_to :user
  has_many :list_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :list_books
  accepts_nested_attributes_for :list_books, allow_destroy: true

  validates :title, presence: true
  validates :list_books, presence: true


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
