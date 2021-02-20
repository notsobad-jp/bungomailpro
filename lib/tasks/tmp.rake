namespace :tmp do
  ## (1) 解約履歴のユーザーをインポート(status: canceled)
  task import_unsubscribed_users: :environment do |_task, _args|
    user_attributes = []
    default_timestamp = Time.zone.parse("2018/4/30")
    CSV.read("tmp/google_migration/unsubscribed_logs.csv", headers: true).each do |user|
      user_attributes << {email: user['メールアドレス'], created_at: default_timestamp, updated_at: Time.zone.parse(user['タイムスタンプ'])}
    end
    User.upsert_all(user_attributes, unique_by: :email)

    # users = User.where(email: user_attributes.pluck(:email))
    # m_log_attributes = []
    # users.each do |user|
    #   m_log_attributes << {user_id: user.id, plan: 'free', status: 'canceled', }
    # end
    # Membership.upsert_all(user_attributes)
  end

  ## (2) GoogleGroupの現在の登録者をインポート（status: active）
  task import_google_group_members: :environment do |_task, _args|
    service = GoogleDirectoryService.instance

    default_timestamp = Time.zone.parse("2018/4/30")
    group_key = 'test@notsobad.jp'
    # group_key = 'bungomail-text@notsobad.jp'

    user_attributes = []
    next_page_token = ""
    loop do
      res = service.list_members(group_key, page_token: next_page_token)
      res.members.each do |m|
        user_attributes << {email: m.email, created_at: default_timestamp, updated_at: default_timestamp}
        p m.email
      end
      next_page_token = res.next_page_token
      break if next_page_token.blank?
      sleep 1
    end
    User.upsert_all(user_attributes)
  end

  ## (3) 購読履歴のユーザーをインポート（timestampを更新）
  task import_subscribed_users: :environment do |_task, _args|
  end

  ## (4) 一時停止履歴のユーザーをインポート（status: paused）
  task import_paused_users: :environment do |_task, _args|
  end
end
