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

  desc 'カテゴリ別の冊数をカウントして保存'
  task categorize_books: :environment do |_task, _args|
    GutenBook::CATEGORIES.each do |category_id, category|
      next if category_id == :all
      books = GutenBook.where(words_count: [category[:range_from]..category[:range_to]])
      books.update_all(category_id: category[:id])
      p "Finished #{category[:id]}: #{books.count} books"
    end
  end
end
