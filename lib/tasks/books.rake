require 'csv'

namespace :books do
  desc 'CSVファイルからbookデータをimport'
  task import: :environment do |_task, _args|
    CSV.foreach('tmp/books.csv') do |fg|
      next if $INPUT_LINE_NUMBER == 1 # 見出し行をスキップ
      next if fg[10] == 'あり'  # 作品著作権の存続コンテンツはスキップ
      next if fg[23] != '著者'  # 翻訳者などのレコードをスキップ（同じ作品が著者レコードで入るはず）

      # ファイルID（古い作品では存在しない場合もあるので、そのときはnil）
      match, author_id, file_id = fg[50].match(%r{https?://www\.aozora\.gr\.jp/cards/(\d+)/files/\d+_(\d+).html}).to_a
      author_id = fg[14].to_i unless match

      # 同じ作品が複数行ある（＝著者が複数）場合、2回目以降は著者を追記する
      if (book = Book.find_by(id: fg[0].to_i))
        author = "#{book.author}, #{fg[15]} #{fg[16]}"
        book.update!(author: author)
        puts "[著者追加] #{fg[0]} #{fg[1]}: #{fg[15]} #{fg[16]}(#{fg[14]})"
      # 未登録の作品ならレコード作成
      else
        Book.create(
          id: fg[0].to_i,
          title: fg[1],
          author: "#{fg[15]} #{fg[16]}",
          author_id: author_id,
          file_id: file_id
        )
        puts "[#{fg[0]}] #{fg[10]}, #{fg[23]}, #{fg[1]}: #{fg[15]} #{fg[16]}(#{fg[14]}), #{file_id}"
      end
    end
  end


  desc 'filesからchaptersを作成する'
  task create_chapters: :environment do |_task, _args|
    Book.where(chapters_count: 0).find_each do |book|
      book.create_chapters
      p "[#{book.id}] #{book.title}"
    rescue StandardError => e
      p '---------'
      p "[#{book.id}] #{e}"
      p '---------'
    end
  end


  desc 'filesから文字数カウントと書き出しを保存'
  task add_words_count_and_beginning: :environment do |_task, _args|
    Book.where.not(chapters_count: 0).where(words_count: nil).find_each do |book|
      text = book.aozora_file_text[0].delete("\r\n　")
      beginning = (text.split("。")[0] + "。").truncate(250)
      book.update!(
        words_count: text.length,
        beginning: beginning
      )
      p "[#{book.id}] #{book.title}"
    rescue StandardError => e
      p '---------'
      p "[#{book.id}] #{e}"
      p '---------'
    end
  end
end
