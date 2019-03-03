# == Schema Information
#
# Table name: comments
#
#  id              :uuid             not null, primary key
#  subscription_id :uuid             not null
#  book_id         :bigint(8)        not null
#  index           :integer          not null
#  comment         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Comment < ApplicationRecord
  belongs_to :subscription
  belongs_to :chapter, foreign_key: %i[book_id index]
end
