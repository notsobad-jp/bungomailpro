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
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      # trial開始時: 公式チャネル購読
      if plan == 'basic' && trialing?
        Subscription.create!(user_id: self.user_id, channel_id: Channel::OFFICIAL_CHANNEL_ID)
      end

      # basic→free: 無料チャネル1つ以外解約・自分チャネルの配信停止？
      if plan == 'free' && active? && membership.plan == 'basic'
        # TODO
      end

      # free-canceled: すべてのチャネル解約・自分チャネルの配信停止？
      if plan == 'free' && canceled?
        # TODO
      end

      self.membership.update!(plan: self.plan, status: self.status)
      self.update!(finished: true)
    end
  end
end
