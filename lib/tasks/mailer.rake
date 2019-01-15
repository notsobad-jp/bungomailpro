namespace :mailer do
  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    # 2月は回数調整のため月初の1・2日に2通送る（うるう年のときは1日のみ）
    today = Time.zone.today
    send_twice = (today.month==2 && today.day==1) || (today.month==2 && today.day==2 && !today.leap)
    n = send_twice ? 2 : 1

    Subscription.includes(:channel, :current_book, :next_chapter).where(next_delivery_date: Time.zone.today).each do |subscription|
      begin
        n.times { subscription.delay.deliver_and_update }
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
