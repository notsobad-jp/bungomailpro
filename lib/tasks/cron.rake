namespace :cron do
  # 月初にmemberships_logs,subscription_logsの変更予約を反映
  task upsert_memberships_and_subscriptions: :environment do |_task, _args|
    begin
      ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
        MembershipLog.apply_all
        SubscriptionLog.apply_all
      end
    rescue => e
      Rails.logger.error "[Error]Cron upserting failed: #{e}"
    end
  end

  # 月初の処理後、membership解約後に残ってる有料チャネルの購読などを削除
  task cancel_forbidden_subscriptions: :environment do |_task, _args|
    begin
      canceled_subs = Subscription.cancel_forbidden_subscriptions || []
      Rails.logger.info "[Success]Canceled #{canceled_subs.length} forbidden subscriptions."
    rescue => e
      Rails.logger.error "[Error]Cron canceling failed: #{e}"
    end
  end
end
