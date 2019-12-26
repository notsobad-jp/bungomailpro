namespace :guten_books do
  task import: :environment do |_task, _args|
    (0..60600).each do |id|
      GutenBook.import_rdf(id)
    end
  end

  task count: :environment do |_task, _args|
    GutenBook.where(words_count: 0).find_each do |guten_book|
      guten_book.count_words
    end
  end
end
