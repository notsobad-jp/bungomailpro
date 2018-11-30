# == Schema Information
#
# Table name: channels
#
#  id                :bigint(8)        not null, primary key
#  user_id           :bigint(8)        not null
#  chapter_id        :bigint(8)
#  title             :string           not null
#  description       :text
#  public            :boolean          default(FALSE), not null
#  books_count       :integer          default(0), not null
#  subscribers_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Channel < ApplicationRecord
  belongs_to :user
  has_many :channel_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :channel_books
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true
  validates :channel_books, length: { maximum: 3 }


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
