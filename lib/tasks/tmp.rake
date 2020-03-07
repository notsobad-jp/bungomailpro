namespace :tmp do
  task count_feeds: :environment do |_task, _args|
    AssignedBook.find_each do |assigned_book|
      assigned_book.update(feeds_count: assigned_book.feeds.count)
      p "Counted: #{assigned_book.id}"
    end
  end

  task generate_magic_tokens: :environment do |_task, _args|
    User.all.each do |user|
      user.generate_magic_login_token!
      p "Generated for #{user.email}: #{user.magic_login_token}"
    end
  end

  task add_scheduled_at_to_feeds: :environment do |_task, _args|
    Feed.where(scheduled: true).each do |feed|
      send_at = Time.zone.parse(feed.send_at.to_s).since(feed.user.utc_offset.minutes)
      feed.update(scheduled_at: send_at)
      p "Updated feed:#{feed.id}, at: #{send_at}"
    end
  end
end
