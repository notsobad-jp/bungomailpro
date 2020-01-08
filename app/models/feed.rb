# == Schema Information
#
# Table name: distributions
#
#  id            :bigint(8)        not null, primary key
#  deliver_at    :date
#  index         :integer          default(1), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  guten_book_id :bigint(8)        not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_distributions_on_guten_book_id  (guten_book_id)
#  index_distributions_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (guten_book_id => guten_books.id)
#  fk_rails_...  (user_id => users.id)
#

class Feed < ApplicationRecord
end
