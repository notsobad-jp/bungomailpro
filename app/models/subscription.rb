class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  validate :check_channel_required_plan, on: :create
  # validate :check_subscriptions_count, on: :create  # 移行時に一時的にカウント超過するので停止
  delegate :email, prefix: true, to: :user

  def self.restart_all
    self.includes(channel: :channel_profile).where(paused: true).each do |sub|
      sub.update!(paused: false)

      # 2021.3.31: まだcallback設定してないのでGroupの配信設定を手動変更
      # sleep 0.5 if sub.channel.google_group_key.present?
      begin
        member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: 'ALL_MAIL')
        @@service.update_member('bungomail-text@notsobad.jp', sub.user_email, member)
        sleep 1
      rescue => e
        logger.error "[Error] google update failed: #{sub.id} #{e}"
        e
      end
    end
  end

  private

  # チャネルごとの購読可能プランを満たしているかチェック
  def check_channel_required_plan
    return if user.plan == 'basic' || channel.required_plan == 'free'
    errors.add(:base, "このチャネルの購読には、Basicプランへの登録が必要です。")
  end

  # 契約プランごとの購読上限数を超えていないかチェック
  def check_subscriptions_count
    return if user.subscriptions.count < Membership::MAXIMUM_SUBSCRIPTIONS_COUNT[user.plan.to_sym]
    errors.add(:base, "購読上限数を超えています。他のチャネルの購読を解除するか、プランをアップグレードしてください。")
  end
end
