# == Schema Information
#
# Table name: assigned_books
#
#  id                                            :uuid             not null, primary key
#  feeds_count                                   :integer
#  status(IN (active finished skipped canceled)) :string           default("active")
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  guten_book_id                                 :bigint(8)        not null
#  user_id                                       :uuid             not null
#
# Indexes
#
#  index_assigned_books_on_guten_book_id  (guten_book_id)
#  index_assigned_books_on_status         (status)
#  index_assigned_books_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (guten_book_id => guten_books.id)
#  fk_rails_...  (user_id => users.id)
#

class AssignedBook < ApplicationRecord
  belongs_to :user
  belongs_to :guten_book
  has_many :feeds, -> { order(:index) }, dependent: :destroy

  def set_feeds
    feeds = []
    contents = self.guten_book.split_text
    send_at = Time.zone.today

    contents.each.with_index(1) do |content, index|
      title = "#{self.guten_book.title}（#{index} of #{contents.count}）"
      feeds << Feed.new(
        assigned_book_id: self.id,
        index: index,
        title: title,
        content: content,
        send_at: send_at
      )
      send_at += 1.day
    end
    Feed.import feeds
  end
end
