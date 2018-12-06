namespace :mailer do
  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Channel.includes([:next_chapter, subscriptions: :user]).where.not(next_chapter_id: nil).each do |channel|
      begin
        UserMailer.with(channel: channel).chapter_email.deliver_later
        channel.delay.set_next_chapter
      rescue => e
        Logger.new(STDOUT).error e
      end
    end
  end

  desc "テスト配信"
  task :test => :environment do |task, args|
    channel = Channel.find(2)
    chapter = Chapter.includes(:book).find_by(book_id: channel.current_book_id, index: channel.index)
    return if !chapter

    UserMailer.with(channel: channel, chapter: chapter).test.deliver_now
    channel.set_next_chapter
  end
end
