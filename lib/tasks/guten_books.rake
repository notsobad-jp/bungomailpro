namespace :guten_books do
  task import: :environment do |_task, _args|
    (0..60600).each do |id|
      GutenBook.import_rdf(id)
    end
  end

  task count_words_and_import_beginning: :environment do |_task, _args|
    GutenBook.all.find_each do |guten_book|
      begin
        next if (text = guten_book.text).nil?
        guten_book.update(
          words_count: text.words.length,
          chars_count: text.gsub(/\s/, "").length,
          beginning: text.first_sentence.truncate(200)
        )
        p "Counted [#{guten_book.id}] #{guten_book.title}"
      rescue => e
        p e
      end
    end
  end

  task update_beginning: :environment do |_task, _args|
    GutenBook.where.not(words_count: nil).find_each do |guten_book|
      guten_book.delay.update_beginning
    end
  end

  desc 'カテゴリ別の冊数をカウントして保存'
  task categorize: :environment do |_task, _args|
    GutenBook::CATEGORIES.each do |category_id, category|
      next if category_id == :all
      books = GutenBook.where(words_count: [category[:range_from]..category[:range_to]])
      books.update_all(category_id: category[:id])
      p "Finished #{category[:id]}: #{books.count} books"
    end
  end

  task ngsl: :environment do |_task, _args|
    ngsl_words = []
    CSV.foreach('tmp/ngsl.csv') do |fg|
      ngsl_words << fg[0]
    end
    # p ngsl_words
    [14838, 1063, 12116, 3206].each do |id|
      book = GutenBook.find(id)
      book_words = book.text.unique_words

      dup_count = (book_words & ngsl_words).count
      ratio = sprintf("%.2f", dup_count/book_words.count.to_f * 100)
      p "--- #{book.title} by #{book.author} ---"
      p "Total: #{book_words.count}, Duplicate: #{dup_count}, Ratio: #{ratio}%"
      p book_words - ngsl_words
      p ""
    end
  end
end
