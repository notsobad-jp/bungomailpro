class MembershipLog < ActivityLog
  belongs_to :user
  belongs_to :membership, foreign_key: :user_id
  has_many :subscription_logs, dependent: :destroy

  def self.apply_all
    logs = self.applicable
    return if logs.blank?
    Membership.upsert_all(logs.map(&:upsert_attributes))
    logs.update_all(finished: true)
  end

  # def apply
  #   ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
  #     self.membership.update!(plan: self.plan, status: self.status)
  #     self.update!(finished: true)
  #   end
  # end

  def upsert_attributes
    attributes = self.slice(:id, :plan, :status)
    attributes[:id] = self.user_id # membershipとlogsでidの値がずれるのを修正
    attributes[:updated_at] = self.apply_at
    attributes
  end

  # membershipの変更をキャンセルして、紐づくsubscriptionsの更新もキャンセルする
  def cancel
    self.update!(canceled: true)
    self.subscription_logs.update_all(canceled: true, updated_at: Time.current)
  end
end
