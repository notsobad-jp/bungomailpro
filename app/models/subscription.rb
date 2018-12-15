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
    # Userがdefault_channelを持ってなければデフォルト指定する
    self.default = self.user.default_channel ? false : true
  end

  after_destroy do
    # Userが他にチャネル持ってるのにdefault_channelがなければ、適当にデフォルト指定する
    alt_channel = self.user.channels.where.not(id: self.channel.id).first
    if alt_channel && self.user.default_channel
      self.user.subscriptions.find_by(channel_id: alt_channel.id).update!(default: true)
    end
  end
end
