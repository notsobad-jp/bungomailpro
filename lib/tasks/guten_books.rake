namespace :guten_books do
  task import: :environment do |_task, _args|
    (0..60600).each do |id|
      GutenBook.import_rdf(id)
    end
  end

  task count: :environment do |_task, _args|
    GutenBook.where(words_count: 0).find_each do |guten_book|
      begin
        next if (text = guten_book.text).nil?
        guten_book.update(
          words_count: text.words.length,
          chars_count: text.gsub(/\s/, "").length
        )
        p "Counted [#{guten_book.id}] #{guten_book.title}"
      rescue => e
        p e
      end
    end
  end
end
