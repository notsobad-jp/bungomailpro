namespace :mailer do
  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Subscription.includes(:channel, :current_book, :next_chapter).where(next_delivery_date: Time.zone.today).each do |subscription|
      begin
        subscription.delay.deliver_and_update
      rescue => error
        Logger.new(STDOUT).error "[ERROR]sub_id:#{subscription.id}, #{error}"
      end
    end
  end

  desc "10日以上前のfeedを削除"
  task :clear_feeds => :environment do |task, args|
    Feed.where("delivered_at < ?", 10.days.ago).delete_all
  end
end
