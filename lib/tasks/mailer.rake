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
    Channel.where.not(book_id: nil).find_each do |channel|
      chapter = Chapter.includes(:book).find_by(book_id: channel.book_id, index: channel.index)
      next if !chapter

      channel.subscriptions.includes(:user).each do |subscription|
        UserMailer.with(subscription: subscription, chapter: chapter)
      end
      #TODO: SendGridに配信予約
    end
  end
end
