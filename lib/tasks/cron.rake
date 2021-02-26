namespace :cron do
  # [月初] memberships_logsの変更予約を反映
  task apply_scheduled_membership_changes: :environment do |_task, _args|
    MembershipLog.applicable.each do |m_log|
      begin
        m_log.apply
      rescue => e
        Rails.logger.error "[Error] Apply failed: #{m_log.id} #{e}"
      end
    end
  end

  # [月初] 一時停止中のsubscriptionを配信再開
  task restart_paused_subscriptions: :environment do |_task, _args|
    Subscription.where(paused: true).each do |sub|
      begin
        sub.update!(paused: false)
      rescue => e
        Rails.logger.error "[Error] Restarting failed: #{sub.id} #{e}"
      end
    end
  end
end
