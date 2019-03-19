# == Schema Information
#
# Table name: comments
#
#  id              :uuid             not null, primary key
#  index           :integer          not null
#  text            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  book_id         :bigint(8)        not null
#  subscription_id :uuid             not null
#
# Indexes
#
#  index_comments_on_book_id                                (book_id)
#  index_comments_on_subscription_id                        (subscription_id)
#  index_comments_on_subscription_id_and_book_id_and_index  (subscription_id,book_id,index) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#  fk_rails_...  (subscription_id => subscriptions.id)
#

class Comment < ApplicationRecord
  belongs_to :subscription
  belongs_to :book
  belongs_to :chapter, foreign_key: %i[book_id index]
end
