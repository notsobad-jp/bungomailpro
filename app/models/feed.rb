# == Schema Information
#
# Table name: feeds
#
#  id              :bigint(8)        not null, primary key
#  subscription_id :uuid             not null
#  book_id         :bigint(8)        not null
#  index           :integer          not null
#  delivered_at    :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Feed < ApplicationRecord
  belongs_to :subscription
  belongs_to :book
  belongs_to :chapter, foreign_key: %i[book_id index]
end
