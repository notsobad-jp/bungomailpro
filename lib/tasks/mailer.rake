namespace :mailer do
  desc '当日分のメール配信をSendGridに予約'
  task schedule: :environment do |_task, _args|
    Subscription.includes(:channel, :current_book, :next_chapter).where(next_delivery_date: Time.zone.today).each do |subscription|
      subscription.delay.deliver_and_update
    rescue StandardError => error
      Logger.new(STDOUT).error "[ERROR]sub_id:#{subscription.id}, #{error}"
    end
  end

  desc '10日以上前のfeedを削除'
  task clear_feeds: :environment do |_task, _args|
    Feed.where('delivered_at < ?', 10.days.ago).delete_all
  end

  desc 'LINE配信(メール配信してnext_chapter更新後にLINE配信するので、1つ前のchapterを配信する)'
  task line: :environment do |_task, _args|
    sub = Channel.find(Channel::BUNGOMAIL_ID).master_subscription
    return if !(prev_chapter = sub.prev_chapter)
    Line.broadcast(prev_chapter)
  end

  # Usage:
  ## 1) All Users: > bundle exec mailer:notification DATE="YYYY-MM-DD HH:ii" NOTIFICATION_ID=XX
  ## 2) Email: > bundle exec mailer:notification DATE="YYYY-MM-DD HH:ii" NOTIFICATION_ID=XX TARGET="bungomail-text@notsobad.jp,lkxhb1yn0m.6fnhsbevhylj4@blog.hatena.ne.jp"
  desc 'お知らせメールの配信'
  task notification: :environment do |_task, _args|
    date = Time.zone.parse(ENV['DATE'])
    notification = Notification.find(ENV['NOTIFICATION_ID'])
    target = ENV['TARGET'].try(:split, ",") || User.all.pluck(:email)

    UserMailer.with(notification: notification, date: date, target: target).notification_email.deliver_now # deliver_nowだけどSendGrid側で予約配信するのでまだ送られない
  end
end
