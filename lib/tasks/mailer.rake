namespace :mailer do
  desc "テスト送信"
  task :tmp_deliver => :environment do |task, args|
    chapter_id = ENV['CHAPTER_ID'].to_i
    subscription_id = ENV['SUBSCRIPTION_ID'].to_i
    deliver_at = ENV['DELIVER_AT']
    # deliver_at = Time.zone.parse(ENV['DELIVER_AT'])

    chapter = Chapter.includes(:book).find(chapter_id)
    subscription = Subscription.includes(:user).find(subscription_id)

    UserMailer.with(deliver_at: deliver_at, chapter: chapter, subscription: subscription).test.deliver_later
  end

  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Channel.includes(subscriptions: :user).where.not(current_book_id: nil).each do |channel|
      chapter = Chapter.includes(:book).find_by(book_id: channel.book_id, index: channel.index)
      next if !chapter

      UserMailer.with(channel: channel, chapter: chapter).test.deliver_later
      channel.delay.set_next_chapter
    end
  end
end
