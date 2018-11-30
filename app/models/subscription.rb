# == Schema Information
#
# Table name: subscriptions
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  channel_id :bigint(8)        not null
#  default    :boolean          default(FALSE), not null
#  deliver_at :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel, counter_cache: :subscribers_count
  serialize :deliver_at
end
