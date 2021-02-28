class MembershipLog < ApplicationRecord
  belongs_to :user
  belongs_to :membership, foreign_key: :user_id

  enum status: { active: 1, trialing: 2, canceled: 3 }

  scope :applicable, -> { where("apply_at < ?", Time.current).where(finished: false, canceled: false) }
  scope :scheduled, -> { where("apply_at > ?", Time.current).where(finished: false, canceled: false) }

  def applicable?
    (self.apply_at < Time.current) && !self.finished? && !self.canceled?
  end

  def self.apply_all
    self.applicable.each do |m_log|
      begin
        m_log.apply
      rescue => e # subscriptionのcallbackでDirectoryAPI叩くので、こけて処理が止まらないようにrescueしてる
        logger.error "[Error] Apply failed: #{m_log.id} #{e}"
      end
    end
  end

  # FIXME: 具体的な処理はmembershipのcallbackでやるべき
  def apply
    return if self.finished? || self.canceled?
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      # trial開始時: 公式チャネル購読
      if plan == 'basic' && trialing?
        Subscription.create!(user_id: self.user_id, channel_id: Channel::OFFICIAL_CHANNEL_ID)
      end

      # basic→free: 無料チャネル以外解約・自作チャネルの削除・配信停止
      if plan == 'free' && active? && membership.plan == 'basic'
        user.channels.destroy_all  # 自作チャネルと配信予約を削除
        user.subscriptions.where.not(channel_id: Channel::JUVENILE_CHANNEL_ID).destroy_all # 児童チャネル以外配信停止
      end

      # free & canceled: すべてのチャネル解約・自作チャネルの削除・配信停止
      if plan == 'free' && canceled?
        user.membership_logs.scheduled.update_all(canceled: true)  # これ以降のステータス変更をすべてキャンセル（念のため）: apply_atが過ぎてるので自分は含まれない
        user.channels.destroy_all  # 自作チャネルと配信予約を削除
        user.subscriptions.destroy_all # すべてのsubscriptionを解約
        user.update!(activation_state: nil) # ログインできなくする
      end

      self.membership.update!(plan: self.plan, status: self.status)
      self.update!(finished: true)
    end
  end
end
