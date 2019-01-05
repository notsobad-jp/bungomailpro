# == Schema Information
#
# Table name: channels
#
#  id                :bigint(8)        not null, primary key
#  token             :string           not null
#  user_id           :bigint(8)        not null
#  title             :string           not null
#  description       :text
#  public            :boolean          default(FALSE), not null
#  books_count       :integer          default(0), not null
#  subscribers_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  last_chapter_id   :bigint(8)
#  next_chapter_id   :bigint(8)
#  deliver_at        :integer          default(8)
#  default           :boolean          default(FALSE), not null
#

class Channel < ApplicationRecord
  belongs_to :user
  has_many :channel_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :channel_books
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true

  before_create do
    self.token = SecureRandom.hex(10)
  end


  def add_book(book)
    self.channel_books.create_with(index: self.last_index + 1).find_or_create_by(book_id: book.id)
  end

  def last_index
    self.channel_books.maximum(:index) || 0
  end
end
