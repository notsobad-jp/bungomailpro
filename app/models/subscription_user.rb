# == Schema Information
#
# Table name: subscription_users
#
#  user_id         :uuid             not null
#  subscription_id :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SubscriptionUser < ApplicationRecord
  self.primary_keys = :subscription_id, :user_id
  belongs_to :user
  belongs_to :subscription
end
