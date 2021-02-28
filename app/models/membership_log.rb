class MembershipLog < ApplicationRecord
  belongs_to :user
  belongs_to :membership, foreign_key: :user_id

  enum status: { active: 1, trialing: 2, canceled: 3 }

  scope :applicable, -> { where("apply_at < ?", Time.current).where(finished: false, canceled: false) }
  scope :scheduled, -> { where("apply_at > ?", Time.current).where(finished: false, canceled: false) }

  def self.apply_all
    self.applicable.each do |m_log|
      begin
        m_log.apply
      rescue => e # subscriptionのcallbackでDirectoryAPI叩くので、こけて処理が止まらないようにrescueしてる
        logger.error "[Error] Apply failed: #{m_log.id} #{e}"
      end
    end
  end

  def apply
    return unless applicable?
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership.update!(plan: self.plan, status: self.status)
      self.update!(finished: true)
    end
  end

  private

  def applicable?
    (self.apply_at < Time.current) && !self.finished? && !self.canceled?
  end
end
