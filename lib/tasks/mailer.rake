namespace :mailer do
  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Channel.includes(subscriptions: :user).where.not(current_book_id: nil).each do |channel|
      chapter = Chapter.includes(:book).find_by(book_id: channel.current_book_id, index: channel.index)
      begin
        UserMailer.with(channel: channel, chapter: chapter).chapter_email.deliver_later
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
