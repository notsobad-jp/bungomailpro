# == Schema Information
#
# Table name: guten_book_users
#
#  id                                            :bigint(8)        not null, primary key
#  status(IN (active finished skipped canceled)) :string
#  created_at                                    :datetime         not null
#  updated_at                                    :datetime         not null
#  guten_book_id                                 :bigint(8)        not null
#  user_id                                       :uuid             not null
#
# Indexes
#
#  index_guten_book_users_on_guten_book_id  (guten_book_id)
#  index_guten_book_users_on_status         (status)
#  index_guten_book_users_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (guten_book_id => guten_books.id)
#  fk_rails_...  (user_id => users.id)
#

class AssignedBook < ApplicationRecord
  belongs_to :user
  belongs_to :guten_book
  has_many :feeds, dependent: :destroy
end
