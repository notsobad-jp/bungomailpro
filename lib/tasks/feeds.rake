namespace :feeds do
  task schedule: :environment do |_task, _args|
    Feed.includes(assigned_book: :user).where(send_at: Date.today, scheduled: false).each do |feed|
      begin
        UserMailer.feed_email(feed).deliver
        # 最後のfeedだったらstatus更新して次の配信をセット
        if feed.index == feed.assigned_book.feeds_count
          feed.assigned_book.update(status: "finished")
          feed.assigned_book.user.delay.assign_book_and_set_feeds
        end
      rescue => e
        logger.error "[FAILED] feed:#{@feed.id}, error: #{e}"
      end
    end
  end
end
