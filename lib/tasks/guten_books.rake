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
    ngsl_words = CSV.read('tmp/ngsl.csv').pluck(0)

    GutenBook.where(category_id: :flash).where.not(author_id: nil).sorted.find_each do |book|
      unique_words = book.text.unique_words

      dup_words = (unique_words & ngsl_words)
      ratio = sprintf("%.1f", dup_words.count/unique_words.count.to_f * 100)

      book.update(
        ngsl_words_count: dup_words.count,
        unique_words_count: unique_words.count,
        ngsl_ratio: ratio,
      )
      p "--- #{book.title} by #{book.author} ---"
      p "Total: #{unique_words.count}, Duplicate: #{dup_words.count}, Ratio: #{ratio}%"

      dir = "tmp/ngsl/#{book.id}"
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      File.write("#{dir}/ngsl.csv", dup_words.map{|w| [w].to_csv }.join)
      File.write("#{dir}/non_ngsl.csv", (unique_words - dup_words).map{|w| [w].to_csv }.join)
      File.write("#{dir}/all.csv", unique_words.map{|w| [w].to_csv }.join)
    end
  end
end
