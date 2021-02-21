namespace :tmp do
  ## (0) GoogleGroupの現在の登録者をそのままダウンロード
  task download_google_group_members: :environment do |_task, _args|
    service = GoogleDirectoryService.instance
    group_key = ENV['GROUP_KEY']

    member_emails = []
    next_page_token = ""
    loop do
      res = service.list_members(group_key, page_token: next_page_token)
      member_emails << res.members.map(&:email)
      next_page_token = res.next_page_token
      break if next_page_token.blank?
      sleep 1
    end

    file_path = 'tmp/google_migration/google_members.txt'
    # file_path = 'tmp/google_migration/dogramagra.txt'
    File.open(file_path, 'w') do |f|
      member_emails.flatten.uniq.each { |s| f.puts(s) }
    end
  end

  ## (1) DLしたGoogleGroupの現在の登録者をインポート（status: active）
  task import_google_group_members: :environment do |_task, _args|
    default_timestamp = Time.zone.parse("2018/4/30")
    juvenile_ch = Channel.find_by(code: "juvenile")

    user_attributes = []
    membership_attributes = []
    m_log_attributes = []
    subscription_attributes = []
    s_log_attributes = []

    File.open('tmp/google_migration/google_members.txt', 'r') do |f|
      f.each_line do |line|
        email = line.chomp
        p email
        next if email == 'info@notsobad.jp'
        uuid = SecureRandom.uuid
        user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: default_timestamp, activation_token: SecureRandom.hex}
        membership_attributes << {id: uuid, plan: 'free', status: 'active', created_at: default_timestamp, updated_at: default_timestamp}
        m_log_attributes << {user_id: uuid, plan: 'free', status: 'active', finished: true, apply_at: default_timestamp, created_at: default_timestamp, updated_at: default_timestamp}
        subscription_attributes << {user_id: uuid, channel_id: juvenile_ch.id, status: 'active', created_at: default_timestamp, updated_at: default_timestamp}
        s_log_attributes << {user_id: uuid, channel_id: juvenile_ch.id, status: 'active', finished: true, apply_at: default_timestamp, created_at: default_timestamp, updated_at: default_timestamp}
      end
    end

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      User.insert_all(user_attributes)
      Membership.insert_all(membership_attributes)
      MembershipLog.insert_all(m_log_attributes)
      Subscription.insert_all(subscription_attributes)
      SubscriptionLog.insert_all(s_log_attributes)
    end
  end

  ## (2) 購読履歴からいまGoogleに存在するユーザーの情報を更新（timestampを更新）
  task import_subscribed_users: :environment do |_task, _args|
    existing_emails = User.pluck(:email)
    CSV.read("tmp/google_migration/subscribed_logs.csv", headers: true).each do |log|
      p log['メールアドレス']
      next if !existing_emails.include?(log['メールアドレス'])
      timestamp = Time.zone.parse(log['タイムスタンプ'])
      user = User.find_by(email: log['メールアドレス'])
      user.update!(created_at: timestamp, updated_at: timestamp) if user
    end
  end

  ## (3) 一時停止履歴からいまGoogleに存在するユーザーをインポート（status: paused → 再開ログを予約）
  task import_paused_users: :environment do |_task, _args|
    juvenile_ch = Channel.find_by(code: "juvenile")
    CSV.read("tmp/google_migration/paused_logs.csv", headers: true).each do |log|
      p log['メールアドレス']
      # 重複でxxx(1)とかなってるメアドは、オリジナルも入ってるはずなので無視してOK
      user = User.find_by(email: log['メールアドレス'])
      timestamp = Time.zone.parse(log['タイムスタンプ'])
      next unless user

      ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
        user.subscriptions.first.update(status: 'paused', updated_at: timestamp)
        user.subscription_logs.create!(channel_id: juvenile_ch.id, status: 'paused', finished: true, created_at: timestamp, updated_at: timestamp, apply_at: timestamp) # 一時停止したときのログ
        user.subscription_logs.create!(channel_id: juvenile_ch.id, status: 'active', created_at: timestamp, updated_at: timestamp, apply_at: Time.zone.parse("2021/03/01")) # 配信再開用のログを予約
      end
    end
  end

  ## (4) 解約履歴からいまGoogleにいないユーザーをインポート(status: canceled)
  task import_unsubscribed_users: :environment do |_task, _args|
    default_timestamp = Time.zone.parse("2018/4/30")

    user_attributes = []
    membership_attributes = []
    m_log_attributes = []

    existing_emails = User.pluck(:email)
    csv_emails = []
    CSV.read('tmp/google_migration/unsubscribed_logs.csv', headers: true).each do |log|
      p log['メールアドレス']
      timestamp = Time.zone.parse(log['タイムスタンプ'])
      email = log['メールアドレス']
      next if existing_emails.include?(email) || csv_emails.include?(email)
      csv_emails << email

      uuid = SecureRandom.uuid
      user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: timestamp}
      membership_attributes << {id: uuid, plan: 'free', status: 'canceled', created_at: default_timestamp, updated_at: timestamp}
      m_log_attributes << {user_id: uuid, plan: 'free', status: 'active', finished: true, apply_at: default_timestamp, created_at: default_timestamp, updated_at: default_timestamp}
      m_log_attributes << {user_id: uuid, plan: 'free', status: 'canceled', finished: true, apply_at: timestamp, created_at: timestamp, updated_at: timestamp}
    end

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      User.insert_all(user_attributes)
      Membership.insert_all(membership_attributes)
      MembershipLog.insert_all(m_log_attributes)
    end
  end

  ## (5) ドグラ・マグラGroupからいまGoogleにいないユーザーをインポート(status: active、 subscriptionはなし)
  task import_dogramagra_users: :environment do |_task, _args|
    default_timestamp = Time.zone.parse("2020/01/01")

    user_attributes = []
    membership_attributes = []
    m_log_attributes = []

    existing_emails = User.pluck(:email)
    File.open('tmp/google_migration/dogramagra.txt', 'r') do |f|
      f.each_line do |line|
        email = line.chomp
        p email
        next if existing_emails.include?(email)

        uuid = SecureRandom.uuid
        user_attributes << {id: uuid, email: email, created_at: default_timestamp, updated_at: default_timestamp}
        membership_attributes << {id: uuid, plan: 'free', status: 'active', created_at: default_timestamp, updated_at: default_timestamp}
        m_log_attributes << {user_id: uuid, plan: 'free', status: 'active', finished: true, apply_at: default_timestamp, created_at: default_timestamp, updated_at: default_timestamp}
      end
    end

    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      User.insert_all(user_attributes)
      Membership.insert_all(membership_attributes)
      MembershipLog.insert_all(m_log_attributes)
    end
  end
end
