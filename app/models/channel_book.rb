# == Schema Information
#
# Table name: channel_books
#
#  id         :bigint(8)        not null, primary key
#  channel_id :bigint(8)        not null
#  book_id    :bigint(8)        not null
#  index      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
