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
    def canonicalize(items)
      canonical, *variants = items.sort_by{ |item| [%w(新字新仮名 新字旧仮名 旧字新仮名 旧字旧仮名).index(item["character_type"]), -item["access_count"]] } # 文字種順 -> アクセス数降順
      books = AozoraBook.where(id: variants.pluck("id"))
      books.update_all(canonical_book_id: canonical["id"])
    end

    AozoraBook.duplicated_books.group_by{|r| r["key"]}.each do |key, items|
      display_key = "#{items.first['author']}『#{items.first['title']} #{items.first['sub_title']}』"
      words_counts = items.pluck("words_count").sort
      if words_counts.include?(0) # どちらかが文字数ゼロのやつ: 無条件除外
        p "skipped: #{display_key}"
        next
      end

      # 過去に正規化の判断をした作品群
      past_judges = {
        canonicalized: [
          [390, 56007, 56880], #うつせみ樋口 一葉
          [389, 55671, 56041], # たけくらべ樋口 一葉
          [387, 55672, 56042], # にごりえ樋口 一葉
          [392, 55674, 56043], # ゆく雲樋口 一葉
          [391, 56008, 56889], # わかれ道樋口 一葉
          [1326, 53808], # わが町織田 作之助 -> 底本違い
          [42309, 59640], # ラプンツェルグリム ヴィルヘルム・カール, グリム ヤーコプ・ルートヴィッヒ・カール -> 底本違い
          [4356, 45688, 52522], # 五所川原太宰 治
          [158, 43751], # 侏儒の言葉芥川 竜之介 -> 書き出しが違うけど同じ作品
          [386, 55670, 56040], # 十三夜樋口 一葉
          [388, 55668, 56039], # 大つごもり樋口 一葉
          [45498, 45499, 46386], # 山越しの阿弥陀像の画因折口 信夫
          [2533, 43494, 46534], # 歌よみに与ふる書正岡 子規
          [4388, 4398, 24379, 24380], # 死者の書折口 信夫
          [69, 45761], # 河童芥川 竜之介
          [1091, 57471], # 竜潭譚泉 鏡花
          [3423, 48403], # 紅玉泉 鏡花
          [98, 24453, 43017], # 蜜柑芥川 竜之介
          [4094, 56010], # 軒もる月樋口 一葉
          [456, 43737, 46322, 48222], # 銀河鉄道の夜宮沢 賢治
          [54728, 57207], # 銭形平次捕物控200 死骸の花嫁野村 胡堂
          [54759, 57215], # 銭形平次捕物控233 鬼の面野村 胡堂
          [50263, 50507], # 革命の研究クロポトキン ピョートル・アレクセーヴィチ -> 書き出しが違うけど同一作品
          [691, 692, 45245], # 高瀬舟森 鴎外
        ],
        skipped: [
          [4132, 4239], # あとがき（『宮本百合子選集』第二巻）宮本 百合子 -> 片方はボツ原稿
          [51114, 51509], # お母さん小川 未明
          [57226, 57227], # かいじん二十めんそう江戸川 乱歩
          [4649, 56933], # みなかみ紀行若山 牧水 -> 単体の作品と、同名の作品集
          [53491, 56731], # アラスカの氷河中谷 宇吉郎 -> 片方は抄録
          [3276, 4044], # 今年こそは宮本 百合子
          [43397, 45111], # 仔牛新美 南吉
          [143, 144, 2325], # 仙人芥川 竜之介 -> 別の2作品と、1つはその解説
          [486, 47858], # 入れ札菊池 寛 -> 同名の戯曲と小説
          [49593, 57354], # 可愛い山石川 欣一 -> 単体の作品と、同名の作品集
          [55497, 55498], # 四行詩富永 太郎
          [186, 4308], # 夢芥川 竜之介
          [45096, 52231], # 島新美 南吉
          [47408, 47409], # 惑ひ伊藤 野枝
          [44456, 44753], # 感想岸田 国士
          [46579, 55785], # 我が生活中原 中也
          [55252, 55316], # 折々の記吉川 英治
          [42487, 42539], # 故郷豊島 与志雄
          [42536, 42565], # 文学以前豊島 与志雄
          [2781, 2784, 2836], # 文芸時評宮本 百合子
          [42458, 45066], # 椎の木豊島 与志雄
          [44644, 44861], # 演出者として岸田 国士
          [55490, 55491, 55492, 55493], # 無題富永 太郎
          [4158, 7913], # 無題（一）宮本 百合子
          [4162, 7929], # 無題（三）宮本 百合子
          [4161, 7917], # 無題（二）宮本 百合子
          [4195, 7936], # 無題（四）宮本 百合子
          [1309, 45617], # 番町皿屋敷岡本 綺堂 -> 同名の戯曲と小説
          [4809, 47926], # 花を持てる女堀 辰雄
          [749, 48249], # 草木塔種田 山頭火
          [503, 47857], # 藤十郎の恋菊池 寛 -> 同名の戯曲と小説
          [44891, 53193], # 隣の花岸田 国士
          [42689, 53804], # 雨織田 作之助
          [54820, 54823], # 雲竹内 浩三
          [4760, 4789], # 魔のひととき原 民喜 -> 同名の詩と散文
        ]
      }

      # 過去判断済みのやつはそれに従って処理
      if past_judges[:canonicalized].include? items.pluck("id").sort
        canonicalize(items)
        p "canonicalized: #{display_key}"
        next
      elsif past_judges[:skipped].include? items.pluck("id").sort
        p "skipped: #{display_key}"
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
          p "[skipped] #{items.pluck('id').sort}, # #{display_key}"
        else
          canonicalize(items)
          p "[canonicalized] #{items.pluck('id').sort}, # #{display_key}"
        end
        next
      end

      # それ以外（自動判定できるやつ）は正規化
      canonicalize(items)
      p "canonicalized: #{display_key}"
    end
  end

  desc 'variantsのアクセス数をcanonicalに合算'
  task aggregate_variants_access_count: :environment do |_task, _args|
    canonical_ids = AozoraBook.where.not(canonical_book_id: nil).pluck(:canonical_book_id).uniq
    AozoraBook.where(id: canonical_ids).each do |canonical|
      variants_count = canonical.variants.sum(:access_count)
      canonical_count = canonical.access_count
      canonical.update!(access_count: canonical_count + variants_count)
      p "Updated #{canonical.title}: #{canonical_count} -> #{canonical_count + variants_count}"
    end
  end
end
