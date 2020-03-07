namespace :feeds do
  task schedule: :environment do |_task, _args|
    AssignedBook.where(status: 'active').each do |assigned_book|
      begin
        feed = assigned_book.next_feed
        UserMailer.feed_email(feed).deliver
        # 最後のfeedだったらstatus更新して次の配信をセット
        if feed.index == assigned_book.feeds_count
          assigned_book.update(status: "finished")
          assigned_book.user.delay.assign_book_and_set_feeds
        end
      rescue => e
        logger.error "[FAILED] feed:#{feed.id}, error: #{e}"
      end
    end
  end
end
