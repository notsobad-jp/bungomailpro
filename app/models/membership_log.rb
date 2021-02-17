class MembershipLog < ApplicationRecord
  belongs_to :user
  has_many :subscription_logs, dependent: :destroy

  def apply_change
    raise 'Job is already finished or canceled.' if self.finished? || self.canceled?
    Membership.upsert(id: self.user_id, plan: self.plan, status: self.status)
    self.update!(finished: true)
  end
end
