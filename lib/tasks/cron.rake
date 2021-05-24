namespace :cron do
  # [月初] memberships_logsの変更予約を反映
  task apply_scheduled_membership_changes: :environment do |_task, _args|
    MembershipLog.apply_all
  end

  # [月初] 一時停止中のsubscriptionを配信再開
  task restart_paused_subscriptions: :environment do |_task, _args|
    Subscription.restart_all
  end

  # [月初] basicプラン購読状況をチェックして、有料チャネルの購読を開始・終了する
  task update_basic_subscription: :environment do |_task, _args|
    # 購読
    # user.email_digest.update!(trial_ended_at: self.trial_end_at)
    # user.subscriptions.new(channel_id: Channel::OFFICIAL_CHANNEL_ID).save!(validate: false) # FIXME: subscriptionsのvalidationが先に来てしまうので一旦スキップ

    # 停止
    # user.channels.destroy_all  # 自作チャネルと配信予約を削除
    # user.subscriptions.where.not(channel_id: Channel::JUVENILE_CHANNEL_ID).destroy_all # 児童チャネル以外配信停止
  end
end
