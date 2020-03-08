namespace :feeds do
  task schedule: :environment do |_task, _args|
    BookAssignment.where(status: 'active').each do |book_assignment|
      begin
        feed = book_assignment.next_feed
        UserMailer.feed_email(feed).deliver
        # 最後のfeedだったらstatus更新して次の配信をセット
        if feed.index == book_assignment.feeds_count
          book_assignment.finished!
          book_assignment.user.delay.assign_book_and_set_feeds
        end
      rescue => e
        logger.error "[FAILED] feed:#{feed.id}, error: #{e}"
      end
    end
  end
end
