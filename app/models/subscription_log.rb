class SubscriptionLog < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  belongs_to :membership_log, required: false

  def apply_change
    raise 'Job is already finished or canceled.' if self.finished? || self.canceled?

    sub = Subscription.find_by(user_id: self.user_id, channel_id: self.channel_id)
    case self.action
    when 'subscribe'
      Subscription.create!(user_id: self.user_id, channel_id: self.channel_id)
    when 'unsubscribe'
      sub.destroy!
    when 'pause'
      sub.update!(paused: true)
    when 'restart'
      sub.update!(paused: false)
    else
      raise 'Required action is not defined.'
    end
    self.update!(finished: true)
  end
end
