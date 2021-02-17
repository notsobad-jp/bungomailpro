class SubscriptionLog < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  belongs_to :membership_log, required: false
end
