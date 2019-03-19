# == Schema Information
#
# Table name: feeds
#
#  id              :bigint(8)        not null, primary key
#  delivered_at    :datetime         not null
#  index           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  book_id         :bigint(8)        not null
#  subscription_id :uuid             not null
#
# Indexes
#
#  index_feeds_on_book_id          (book_id)
#  index_feeds_on_delivered_at     (delivered_at)
#  index_feeds_on_subscription_id  (subscription_id)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#  fk_rails_...  (subscription_id => subscriptions.id)
#

class Feed < ApplicationRecord
  belongs_to :subscription
  belongs_to :book
  belongs_to :chapter, foreign_key: %i[book_id index]

  def comment
    subscription.comments.find_by(book_id: book_id, index: index)
  end
end
