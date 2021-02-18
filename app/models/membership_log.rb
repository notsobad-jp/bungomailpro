class MembershipLog < ApplicationRecord
  belongs_to :user
  has_many :subscription_logs, dependent: :destroy

  scope :applicable, -> { where("apply_at < ?", Time.current).where(finished: false, canceled: false) }

  def self.apply_all
    logs = self.applicable
    return if logs.blank?
    Membership.upsert_all(logs.map(&:upsert_attributes))
    logs.update_all(finished: true)
  end

  def upsert_attributes
    attributes = self.slice(:id, :plan, :status)
    attributes[:id] = self.user_id # membershipとlogsでidの値がずれるのを修正
    attributes[:updated_at] = self.apply_at
    attributes
  end
end
