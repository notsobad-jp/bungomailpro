namespace :tmp do
  task count_feeds: :environment do |_task, _args|
    AssignedBook.find_each do |assigned_book|
      assigned_book.update(feeds_count: assigned_book.feeds.count)
      p "Counted: #{assigned_book.id}"
    end
  end
end
