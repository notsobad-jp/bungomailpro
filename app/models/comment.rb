# == Schema Information
#
# Table name: comments
#
#  id         :bigint(8)        not null, primary key
#  channel_id :bigint(8)        not null
#  text       :text
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Comment < ApplicationRecord
  belongs_to :channel
end
