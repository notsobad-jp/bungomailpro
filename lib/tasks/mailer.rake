namespace :mailer do
  desc "テスト送信"
  task :tmp_deliver, ['delivery_id'] => :environment do |task, args|
    delivery = Delivery.find(args[:delivery_id])
    delivery.deliver
    p "delivered #{delivery.id}"
  end

  desc "当日分のメール配信をSendGridに予約"
  task :schedule => :environment do |task, args|
    Channel.where.not(book_id: nil).find_each do |channel|
      p "----"
      p channel.title
      chapter = Chapter.includes(:book).find_by(book_id: channel.book_id, index: channel.index)
      next if !chapter
      p "#{chapter.book.title} #{chapter.index}"

      subscribers = channel.subscribers.pluck(:email)
      p subscribers

      #TODO: SendGridに配信予約
    end
  end
end
