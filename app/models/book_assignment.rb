# == Schema Information
#
# Table name: book_assignments
#
#  id            :uuid             not null, primary key
#  feeds_count   :integer          default(0)
#  status        :integer          default("stocked"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  guten_book_id :bigint(8)        not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_book_assignments_on_guten_book_id  (guten_book_id)
#  index_book_assignments_on_status         (status)
#  index_book_assignments_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (guten_book_id => guten_books.id)
#  fk_rails_...  (user_id => users.id)
#

class BookAssignment < ApplicationRecord
  belongs_to :channel
  belongs_to :book, polymorphic: true
  has_many :feeds, -> { order(:index) }, dependent: :destroy

  enum status: { stocked: 0, active: 1, finished: 2, skipped: 3, canceled: 4 }

  def set_feeds
    feeds = []
    contents = self.guten_book.contents(words_per: self.user.words_per_day)

    contents.each.with_index(1) do |content, index|
      title = "#{self.guten_book.title}（#{index} of #{contents.count}）"
      feeds << Feed.new(
        book_assignment_id: self.id,
        index: index,
        title: title,
        content: content
      )
    end
    Feed.import feeds

    self.update(feeds_count: feeds.count)
  end

  def next_feed
    self.feeds.where(scheduled_at: nil).first
  end
end
