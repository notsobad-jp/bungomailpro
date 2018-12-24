# == Schema Information
#
# Table name: subscriptions
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  channel_id :bigint(8)        not null
#  default    :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel, counter_cache: :subscribers_count

  before_create do
    # 自作channelで、かつuserがdefault_channelを持ってなければデフォルト指定する
    self.default = self.channel_owned? && self.user.subscriptions.find_by(default: true).blank?
  end

  def channel_owned?
    self.user_id == self.channel.user_id
  end
end
