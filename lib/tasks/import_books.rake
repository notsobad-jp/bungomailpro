require 'nokogiri'
require 'open-uri'

namespace :import_books do
  desc "青空文庫から指定の作品をDBにインポート"
  task :import, ['url'] => :environment do |task, args|
    # scrape and parse Aozora URL
    def parse_html(url)
      charset = nil
      html = open(url) do |f|
        charset = f.charset
        f.read
      end

      doc = Nokogiri::HTML.parse(html, nil, charset)
      title = doc.css('.title').inner_text
      author = doc.css('.author').inner_text
      text = doc.css('.main_text').inner_text

      return [title, author, text]
    end

    title, author, text = parse_html(args['url'])
    aozora_id = args['url'].split('/').last.split('_')[0].to_i

    book = Book.find_or_create_by(aozora_id: aozora_id)
    book.update(
      title: title,
      author: author,
      text: text
    )
    p "#{title} saved!"
  end

  desc "テキストを分割してbook_chaptersに格納"
  task :split_texts, ['aozora_id'] => :environment do |task, args|
    @book = Book.find_by(aozora_id: args['aozora_id'])
    chapters = @book.split_texts

    chapters.each.with_index(1) do |chapter, index|
      BookChapter.create(
        book_id: @book.id,
        index: index,
        text: chapter
      )
      p "#{@book.title} - #{index} saved!"
    end
  end



  desc "青空文庫から直接booksとchaptersにインポート"
  task :direct_import, ['url'] => :environment do |task, args|
    # scrape and parse Aozora URL
    def parse_html(url)
      charset = nil
      html = open(url) do |f|
        charset = f.charset
        f.read
      end

      doc = Nokogiri::HTML.parse(html, nil, charset)
      title = doc.css('.title').inner_text
      author = doc.css('.author').inner_text
      text = doc.css('.main_text').inner_text

      return [title, author, text]
    end

    title, author, text = parse_html(args['url'])
    aozora_id = args['url'].split('/').last.split('_')[0].to_i

    @book = Book.find_or_create_by(aozora_id: aozora_id)
    @book.update(
      title: title,
      author: author
    )

    chapters = @book.split_text(text)

    chapters.each.with_index(1) do |chapter, index|
      @book.chapters.create(
        index: index,
        text: chapter
      )
      p "#{@book.title} - #{index} saved!"
    end
  end

end
