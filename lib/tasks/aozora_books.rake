require 'csv'
include ActionView::Helpers::TextHelper

namespace :aozora_books do
  desc 'CSVファイルからbookデータをimport'
  task import: :environment do |_task, _args|
    CSV.foreach('tmp/aozora_books.csv', headers: true) do |fg|
      next if fg["役割フラグ"] != '著者'  # 翻訳者などのレコードをスキップ（同じ作品が著者レコードで入るはず）

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
          sub_title: fg["副題"],
          author: "#{fg[15]} #{fg[16]}",
          author_id: author_id,
          file_id: file_id,
          rights_reserved: fg[10] == 'あり',
          first_edition: fg[7].presence,
          published_at: published_match ? published_match[1] : nil,
          character_type: fg[9].presence,
          juvenile: fg[8].match(/K\d{3}/i).present?,
          published_date: fg["公開日"],
          last_updated_date: fg["最終更新日"],
          source: fg["底本名1"],
        )
        puts "[#{fg[0]}] #{fg[10]}, #{fg[23]}, #{fg[1]}: #{fg[15]} #{fg[16]}(#{fg[14]}), #{file_id}"
      end
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
    (2009..2021).each do |year|
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


  desc '同一作品の正規化'
  task canonicalize_variant_books: :environment do |_task, _args|
    skipped_books = {}
    AozoraBook.duplicated_books.group_by{|r| r["key"]}.each do |key, items|
      words_counts = items.pluck("words_count").sort
      if words_counts.include?(0) # どちらかが文字数ゼロのやつ: 無条件除外
        skipped_books[key] = items
        p "skipped: #{key}"
        next
      end

      more_than_two_items = items.length > 2 && 'more than 2 items' # itemが3つ以上あるやつ
      different_words_count = words_counts[0] * 2 < words_counts[1] && 'different words count' # 文字数が違うやつ
      if !more_than_two_items
        trigram = Trigram.compare(*items.pluck("beginning"))
        different_beginning = trigram < 0.1 && 'different beginning' # 書き出しが全然違うやつ
      end

      # 自動判定できないやつは、標準入力で正規化するかどうか手動判断
      if more_than_two_items || different_beginning || different_words_count
        p "-----#{ more_than_two_items || different_beginning || different_words_count }-----"
        pp items.map{|m| m.reject{|k,v| k == 'key' } }
        p "Press any key to canonicalize, or press enter to skip:"
        if $stdin.gets.blank?
          skipped_books[key] = items
          p "skipped: #{key}"
          next
        end
      end

      # 正規化処理
      canonical, *variants = items.sort_by{ |item| [AozoraBook::CHARACTER_ORDER.index(item["character_type"]), -item["access_count"]] }
      books = AozoraBook.where(id: variants.pluck("id"))
      books.update_all(canonical_book_id: canonical["id"])
      p "canonicalized: #{key}"
    end
    p "====================="
    p "Skipped books:"
    pp skipped_books.keys
  end
end
