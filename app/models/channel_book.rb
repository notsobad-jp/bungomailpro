# == Schema Information
#
# Table name: channel_books
#
#  id         :bigint(8)        not null, primary key
#  comment    :text
#  index      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint(8)        not null
#  channel_id :uuid             not null
#
# Indexes
#
#  index_channel_books_on_book_id                 (book_id)
#  index_channel_books_on_channel_id              (channel_id)
#  index_channel_books_on_channel_id_and_book_id  (channel_id,book_id) UNIQUE
#  index_channel_books_on_channel_id_and_index    (channel_id,index) UNIQUE
#  index_channel_books_on_index                   (index)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#  fk_rails_...  (channel_id => channels.id)
#

class ChannelBook < ApplicationRecord
  belongs_to :channel, counter_cache: :books_count, optional: true
  belongs_to :book

  validates :index, presence: true
  validates :channel_id, uniqueness: { scope: [:book_id] }

  def editable?
    index > channel.latest_index
  end

  def next
    channel.channel_books.where('index > ?', index).first
  end

  def prev
    channel.channel_books.where('index < ?', index).last if index > 1
  end
end
