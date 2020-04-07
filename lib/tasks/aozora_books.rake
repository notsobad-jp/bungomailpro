require 'csv'
include ActionView::Helpers::TextHelper

namespace :aozora_books do
  desc 'CSVファイルからbookデータをimport'
  task import: :environment do |_task, _args|
    CSV.foreach('tmp/aozora_books.csv') do |fg|
      next if fg[0] == '作品ID' # 見出し行をスキップ
      next if fg[23] != '著者'  # 翻訳者などのレコードをスキップ（同じ作品が著者レコードで入るはず）

      # ファイルID（古い作品では存在しない場合もあるので、そのときはnil）
      match, author_id, file_id = fg[50].match(%r{https?://www\.aozora\.gr\.jp/cards/(\d+)/files/\d+_(\d+).html}).to_a
      author_id = fg[14].to_i unless match

      # 同じ作品が複数行ある（＝著者が複数）場合、2回目以降は著者を追記する
      if (book = AozoraBook.find_by(id: fg[0].to_i))
        author = "#{book.author}, #{fg[15]} #{fg[16]}"
        book.update!(author: author)
        puts "[著者追加] #{fg[0]} #{fg[1]}: #{fg[15]} #{fg[16]}(#{fg[14]})"
      # 未登録の作品ならレコード作成
      else
        published_match = fg[7].presence&.match(/\D((?>18|19)\d{2})\D/) # 18xxか19xxの4桁数字にのみマッチさせる
        AozoraBook.create!(
          id: fg[0].to_i,
          title: fg[1],
          author: "#{fg[15]} #{fg[16]}",
          author_id: author_id,
          file_id: file_id,
          rights_reserved: fg[10] == 'あり',
          first_edition: fg[7].presence,
          published_at: published_match ? published_match[1] : nil,
          character_type: fg[9].presence,
        )
        puts "[#{fg[0]}] #{fg[10]}, #{fg[23]}, #{fg[1]}: #{fg[15]} #{fg[16]}(#{fg[14]}), #{file_id}"
      end
    end
  end

  # 既存のレコードをCSVからアップデート（著者タイプで同じ本が複数レコードあるので注意）
  task update: :environment do |_task, _args|
    CSV.foreach('tmp/aozora_books.csv') do |fg|
      next if fg[0] == '作品ID' # 見出し行をスキップ
      next if fg[23] != '著者'  # 翻訳者などのレコードをスキップ（同じ作品が著者レコードで入るはず）

      # ファイルID（古い作品では存在しない場合もあるので、そのときはnil）
      match, author_id, file_id = fg[50].match(%r{https?://www\.aozora\.gr\.jp/cards/(\d+)/files/\d+_(\d+).html}).to_a
      author_id = fg[14].to_i unless match

      book = AozoraBook.find_by(id: fg[0].to_i)
      next unless book

      next unless fg[8].match(/K\d{3}/i)

      # published_match = fg[7].presence&.match(/\D((?>18|19)\d{2})\D/) # 18xxか19xxの4桁数字にのみマッチさせる
      book.update!(
        juvenile: true
        # first_edition: fg[7].presence,
        # published_at: published_match ? published_match[1] : nil,
        # character_type: fg[9].presence,
      )
      puts "[Updated] #{fg[0]}"
      # puts "[Updated] #{fg[0]} #{fg[1]}: #{fg[7]} #{published_match} #{fg[9]}"
    end
  end


  desc 'filesから文字数カウントと書き出しを保存'
  task add_words_count_and_beginning: :environment do |_task, _args|
    AozoraBook.where(words_count: 0).find_each do |book|
      text, footnote = book.aozora_file_text
      book.update!(
        words_count: text.length,
        beginning: book.beginning_from_file,
        footnote: footnote
      )
      p "[#{book.id}] #{book.title}"
    rescue StandardError => e
      p '---------'
      p "[#{book.id}] #{e}"
      p '---------'
    end
  end


  desc 'filesからアクセス数ランキングをDBに保存'
  task save_access_ranking: :environment do |_task, _args|
    (2009..2020).each do |year|
      p "Year: #{year}"
      (1..12).each do |month|
        p "- Month: #{month}"
        file_path = "tmp/aozorabunko/access_ranking/#{year}_#{"%#02d" % month}_xhtml.html"
        html = File.open(file_path, &:read)

        charset = 'UTF-8'
        doc = Nokogiri::HTML.parse(html, nil, charset)
        doc.search('tr').each_with_index do |tr, index|
          next if index == 0
          url = tr.at('td:nth-child(2)').css('a').attribute('href').value
          id = /https:\/\/www\.aozora\.gr\.jp\/cards\/\d{6}\/card(\d+)\.html/.match(url)[1]
          access = tr.at('td:nth-child(4)').inner_text.to_i

          book = AozoraBook.find(id)
          book.update(access_count: book.access_count + access)
        end
      rescue StandardError => e
        p e
      end
    end
  end


  desc 'カテゴリ別の冊数をカウントして保存'
  task categorize_books: :environment do |_task, _args|
    AozoraBook::CATEGORIES.each do |category_id, category|
      next if category_id == :all
      books = AozoraBook.where(words_count: [category[:range_from]..category[:range_to]])
      books.update_all(category_id: category[:id])
      p "Finished #{category[:id]}: #{books.count} books"
    end
  end
end
