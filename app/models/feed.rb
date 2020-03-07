# == Schema Information
#
# Table name: feeds
#
#  id               :bigint(8)        not null, primary key
#  content          :text
#  index            :integer          default(1), not null
#  scheduled        :boolean          default(FALSE)
#  scheduled_at     :datetime
#  send_at          :date
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assigned_book_id :uuid             not null
#
# Indexes
#
#  index_feeds_on_assigned_book_id  (assigned_book_id)
#  index_feeds_on_scheduled_at      (scheduled_at)
#
# Foreign Keys
#
#  fk_rails_...  (assigned_book_id => assigned_books.id)
#

class Feed < ApplicationRecord
  belongs_to :assigned_book
  has_one :user, through: :assigned_book
end
