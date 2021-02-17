class MembershipLog < ApplicationRecord
  belongs_to :user
  has_many :subscription_logs, dependent: :destroy
end
