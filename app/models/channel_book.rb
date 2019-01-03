# == Schema Information
#
# Table name: channel_books
#
#  id         :bigint(8)        not null, primary key
#  channel_id :bigint(8)        not null
#  book_id    :bigint(8)        not null
#  index      :integer          not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ChannelBook < ApplicationRecord
  belongs_to :channel, counter_cache: :books_count, required: false
  belongs_to :book

  validates :index, presence: true
  validates :channel_id, uniqueness: { scope: [:book_id] }

  def first_chapter
    Chapter.find_by(book_id: self.book_id, index: 1)
  end
end
