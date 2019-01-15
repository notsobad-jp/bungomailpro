namespace :mailer do
  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Subscription.includes(:channel, :current_book, :next_chapter).where(next_delivery_date: Time.zone.today).each do |subscription|
      UserMailer.with(subscription: subscription).chapter_email.deliver_later
      subscription.create_feed
      subscription.delay.set_next_chapter
    end
  end

  desc "10日以上前のfeedを削除"
  task :clear_feeds => :environment do |task, args|
    Feed.where("delivered_at < ?", 10.days.ago).delete_all
  end
end
