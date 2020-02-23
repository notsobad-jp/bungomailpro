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
end
