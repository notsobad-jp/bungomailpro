class ChannelSubscriptionLog < ApplicationRecord
  enum action: { subscribed: 1, paused: 2, unsubscribed: 3 }
end
