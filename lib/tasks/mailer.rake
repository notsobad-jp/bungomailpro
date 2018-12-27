namespace :mailer do
  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Channel.includes([:next_chapter, subscriptions: :user]).where.not(next_chapter_id: nil).each do |channel|
      UserMailer.with(channel: channel).next_chapter_email.deliver_later
      channel.delay.set_next_chapter
    end
  end

  desc "当日のメールを全員に再送（障害時など）"
  task :resend => :environment do |task, args|
    Channel.includes([:next_chapter, subscriptions: :user]).sent_today.each do |channel|
      UserMailer.with(channel: channel).last_chapter_email.deliver_later
    end
  end
end
