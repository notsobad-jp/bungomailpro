namespace :cron do
  task revert_paused_users: :environment do |_task, _args|
    service = GoogleDirectoryService.instance
    member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: 'ALL_MAIL')

    # 先月一時停止したユーザーのメアド一覧を取得
    paused_emails = SubscriptionLog.where(type: "paused", created_at: Time.current.last_month.all_month).pluck(:email).uniq
    count = paused_emails.length
    paused_emails.each do |email|
      begin
        service.patch_member('test@notsobad.jp', email, member)
        p "success!"
      rescue => e
        p e
        count -= 1
      end
    end
    p "[FINISHED] success: #{count}, failure: #{paused_emails.length - count}"
  end
end
