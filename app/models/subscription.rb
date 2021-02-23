class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  enum status: { active: 1, paused: 2, canceled: 3 }

  # 不正なsubscription: freeプランユーザーがfree以外のchannelをまだ購読している場合
  scope :forbidden, -> {includes(:channel, user: :membership).where(status: 'active', user: {memberships: {plan: 'free'}}).where.not(channel: {id: Channel::FREE_CHANNEL_IDS}) }

  # membership解約後に残ってる有料チャネルの購読などを削除
  def self.cancel_forbidden_subscriptions
    forbidden_subs = Subscription.forbidden
    return if forbidden_subs.blank?

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      # subscription停止
      forbidden_subs.update_all(status: :canceled)

      # 一応subscription_logも残す
      sub_logs = []
      forbidden_subs.each do |sub|
        google_action = 'delete' if sub.channel.google_group_key
        sub_log_attributes = sub.slice(:user_id, :channel_id, :status).merge(finished: true, google_action: google_action)
        sub_logs << sub_log_attributes
        next unless google_action

        # GoogleGroupに紐づく場合はそっちの状態も更新
        sub_log = SubscriptionLog.new(sub_log_attributes)
        sub_log.update_google_subscription  # メソッド側で例外処理してるのでそのままでOK
      end
      SubscriptionLog.insert_all(sub_logs) if sub_logs.present?
    end
    forbidden_subs
  end
end
