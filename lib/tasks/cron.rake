namespace :cron do
  # [月初] memberships_logsの変更予約を反映
  task apply_scheduled_membership_changes: :environment do |_task, _args|
    MembershipLog.apply_all
  end

  # [月初] 一時停止中のsubscriptionを配信再開
  task restart_paused_subscriptions: :environment do |_task, _args|
    Subscription.restart_all
  end
end
