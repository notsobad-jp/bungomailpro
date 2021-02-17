class SubscriptionLog < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  belongs_to :membership_log, required: false

  def apply_change
    raise 'Job is already finished or canceled.' if self.finished? || self.canceled?
    Subscription.upsert(user_id: self.user_id, channel_id: self.channel_id, status: self.status)
    self.update!(finished: true)
  end
end
