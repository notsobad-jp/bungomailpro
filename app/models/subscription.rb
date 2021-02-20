class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  # 不正なsubscription: freeプランユーザーがfree以外のchannelをまだ購読している場合
  scope :forbidden, -> {includes(:channel, user: :membership).where(status: 'active', user: {memberships: {plan: 'free'}}).where.not(channel: {id: Channel::FREE_CHANNEL_IDS}) }

  # membership解約後に残ってる有料チャネルの購読などを削除
  def self.cancel_forbidden_subscriptions
    forbidden_subs = Subscription.forbidden
    return if forbidden_subs.blank?

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      forbidden_subs.update_all(status: 'canceled')
      sub_logs = []
      forbidden_subs.each do |sub|
        google_action = 'delete' if sub.channel.google_group_key
        sub_logs << sub.slice(:user_id, :channel_id, :status).merge(finished: true, google_action: google_action)
        if google_action
          # TODO: GoogleGroupからも削除
        end
      end
      SubscriptionLog.insert_all(sub_logs) if sub_logs.present?
    end
    forbidden_subs
  end
end
