namespace :mailer do
  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Subscription.includes(:channel, :current_book, :next_chapter).where(next_delivery_date: Time.zone.today).each do |subscription|
      UserMailer.with(subscription: subscription).chapter_email.deliver_later
      subscription.delay.set_next_chapter
    end
  end
end
