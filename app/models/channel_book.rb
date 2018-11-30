# == Schema Information
#
# Table name: channel_books
#
#  id         :bigint(8)        not null, primary key
#  channel_id :bigint(8)
#  book_id    :bigint(8)
#  index      :integer          not null
#  status     :integer          default(1), not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ChannelBook < ApplicationRecord
  belongs_to :channel, counter_cache: :books_count
  belongs_to :book

  validates :index, presence: true
  validates :status, inclusion: { in: %i(1 2 3) }
end
