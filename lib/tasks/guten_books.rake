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

  desc 'カテゴリ別の冊数をカウントして保存'
  task categorize: :environment do |_task, _args|
    GutenBook::CATEGORIES.each do |category_id, category|
      next if category_id == :all
      books = GutenBook.where(words_count: [category[:range_from]..category[:range_to]])
      books.update_all(category_id: category[:id])
      p "Finished #{category[:id]}: #{books.count} books"
    end
  end

  # 時間がかかるのでworkerを複数動かしておいてから実行して、並列で処理させる
  desc '書き出しの一文を取得して保存'
  task update_beginning: :environment do |_task, _args|
    GutenBook.where(language: "en").where.not(category_id: nil).where.not(author_id: nil).find_each do |book|
      book.delay.update_beginning
      p "Queued #{book.id}"
    end
  end

  # 時間がかかるのでworkerを複数動かしておいてから実行して、並列で処理させる
  desc '全文を単語化→NGSL比率を計算して、非NGSL単語をCSVにして保存'
  task update_ngsl: :environment do |_task, _args|
    ngsl_words = CSV.read('db/seeds/ngsl.csv').pluck(0)

    # GutenBook.where(language: 'en').where.not(category_id: nil).where.not(author_id: nil).sorted.find_each do |book|
    GutenBook.where(language: 'en').where(category_id: ['flash', 'shortshort']).where.not(author_id: nil).sorted.find_each do |book|
      book.delay.update_ngsl(ngsl_words)
      p "Queued #{book.id}"
    end
  end
end
