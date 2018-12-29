require 'csv'

namespace :books do
  desc "CSVファイルからbookデータをimport"
  task :import => :environment do |task, args|
    existing_books = Book.all.pluck(:id)

    books = []
    CSV.foreach('tmp/books.csv') do |fg|
      next if $. == 1  # 見出し行をスキップ
      next if existing_books.include? fg[0].to_i  # すでに登録済みの作品はスキップ
      next if fg[10] == 'あり'  # 作品著作権の存続コンテンツはスキップ
      next if fg[23] != '著者'  # 翻訳者などのレコードをスキップ（同じ作品が著者レコードで入るはず）

      existing_books << fg[0].to_i

      # ファイルID（古い作品では存在しない場合もあるので、そのときはnil）
      match, file_id = fg[50].match(/https?:\/\/www\.aozora\.gr\.jp\/cards\/\d+\/files\/\d+_(\d+).html/).to_a

      books << Book.new(
        id: fg[0].to_i,
        title: fg[1],
        author: "#{fg[15]} #{fg[16]}",
        author_id: fg[14].to_i,
        file_id: file_id,
      )
      puts "[#{fg[0]}] #{fg[10]}, #{fg[23]}, #{fg[1]}: #{fg[15]} #{fg[16]}(#{fg[14]}), #{file_id}"
    end
    Book.import! books
    p "Imported #{books.count} books!"
  end


  desc "filesからchaptersを作成する"
  task :create_chapters => :environment do |task, args|
    Book.where(chapters_count: 0).find_each do |book|
      begin
        book.create_chapters
        p "[#{book.id}] #{book.title}"
      rescue => e
        p "---------"
        p "[#{book.id}] #{e}"
        p "---------"
      end
    end
  end
end
