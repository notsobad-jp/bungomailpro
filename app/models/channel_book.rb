# == Schema Information
#
# Table name: channel_books
#
#  id         :bigint(8)        not null
#  channel_id :bigint(8)        not null, primary key
#  book_id    :bigint(8)        not null, primary key
#  index      :integer          not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  delivered  :boolean          default(FALSE), not null
#

class ChannelBook < ApplicationRecord
  self.primary_keys = :channel_id, :book_id
  belongs_to :channel, counter_cache: :books_count, required: false
  belongs_to :book

  validates :index, presence: true
  validates :channel_id, uniqueness: { scope: [:book_id] }
end
