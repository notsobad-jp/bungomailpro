# == Schema Information
#
# Table name: feeds
#
#  id                 :bigint(8)        not null, primary key
#  content            :text
#  index              :integer          default(1), not null
#  scheduled_at       :datetime
#  title              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  book_assignment_id :uuid             not null
#
# Indexes
#
#  index_feeds_on_book_assignment_id  (book_assignment_id)
#  index_feeds_on_scheduled_at        (scheduled_at)
#
# Foreign Keys
#
#  fk_rails_...  (book_assignment_id => book_assignments.id)
#

class Feed < ApplicationRecord
  belongs_to :book_assignment
  # has_one :user, through: :book_assignment
end
