# == Schema Information
#
# Table name: feeds
#
#  id              :bigint(8)        not null, primary key
#  subscription_id :bigint(8)        not null
#  book_id         :bigint(8)        not null
#  chapter_index   :integer          not null
#  delivered_at    :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Feed < ApplicationRecord
  belongs_to :subscription
end
