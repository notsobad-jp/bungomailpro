# == Schema Information
#
# Table name: feeds
#
#  id            :bigint(8)        not null, primary key
#  content       :text
#  index         :integer          default(1), not null
#  scheduled     :boolean          default(FALSE)
#  send_at       :date
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  guten_book_id :bigint(8)        not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_feeds_on_guten_book_id                        (guten_book_id)
#  index_feeds_on_guten_book_id_and_user_id_and_index  (guten_book_id,user_id,index) UNIQUE
#  index_feeds_on_user_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (guten_book_id => guten_books.id)
#  fk_rails_...  (user_id => users.id)
#

class Feed < ApplicationRecord
  belongs_to :user
  belongs_to :guten_book

  def schedule_email
    UserMailer.feed_email(self).deliver
  end
end
