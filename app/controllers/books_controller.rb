require 'open-uri'

class BooksController < ApplicationController
  def index
    @keyword = params[:keyword]
    @target = params[:target] || {work: true, author: true}
    @channels = current_user.channels if current_user

    # 検索実行時
    if @keyword.present?
      Algolia.init(
        application_id: ENV['ALGOLIA_ID'],
        api_key:        ENV['ALGOLIA_KEY']
      )
      index = Algolia::Index.new('books')

      # 検索対象が絞られてるとき
      restrictSearchableAttributes = []
      if @target[:work] && !@target[:author]
        restrictSearchableAttributes = ['作品名', '作品名読み', '副題', '副題読み', '原題']
      elsif @target[:author] && !@target[:work]
        restrictSearchableAttributes = ['姓', '姓読み', '姓ローマ字', '名', '名読み', '名ローマ字']
      end
      @results = index.search(@keyword, restrictSearchableAttributes: restrictSearchableAttributes)['hits']

    # 初期表示
    else
      @popular_authors = [
        { id: 148, name: '夏目漱石' },
        { id: 879, name: '芥川龍之介' },
        { id: 1779, name: '江戸川乱歩' },
        { id: 81, name: '宮沢賢治' }
      ]
      popular_book_ids = [] #TODO
      @popular_books = Book.find(popular_book_ids)
    end
  end


  def search
    # url = params[:url]
    #
    # # 図書カードURLが来てたら、ファイルURLに変換
    # if url.match(/https?:\/\/www\.aozora\.gr\.jp\/cards\/(\d+)\/card\d+.html/)
    #   url = Book.card_to_file_url(url)
    # end
    #
    # match = url.match(/https?:\/\/www.aozora.gr.jp\/cards\/(\d+)\/files\/(\d+)_\d+\.html/).to_a
    # if match.blank?
    #   flash[:error] = 'URLが正しくないようです。。XHTMLファイルか図書カードのURLを入力してください。'
    #   return redirect_to books_path
    # end
    #
    # book = Book.find_by(id: match[2])
    # return redirect_to book_path(book) if book
    #
    # book_params = Book.parse_html(url)
    # text = book_params.delete(:text)
    # book = Book.new(book_params)
    #
    # chapters = []
    # Book.splited_text(text).each.with_index(1) do |chapter, index|
    #   chapters << Chapter.new(index: index, text: chapter)
    # end
    # book.chapters = chapters
    #
    # if book.save
    #   redirect_to book_path book
    # else
    #   flash[:error] = '本が見つかりませんでした…。URLをもう一度確認してください。'
    #   redirect_to books_path
    # end
  end

  def scrape
    url = params[:url]

    # 図書カードURLが来てたら、ファイルURLに変換
    if url.match(/https?:\/\/www\.aozora\.gr\.jp\/cards\/(\d+)\/card\d+.html/)
      url = Book.card_to_file_url(url)
    end

    match = url.match(/https?:\/\/www.aozora.gr.jp\/cards\/(\d+)\/files\/(\d+)_\d+\.html/).to_a
    return if !match

    book = Book.find_by(id: match[2])
    render json: book.attributes and return if book

    book_params = Book.parse_html(url)
    text = book_params.delete(:text)

    ActiveRecord::Base.transaction do
      book = Book.create!(book_params)
      Book.split_text(text).each.with_index(1) do |chapter, index|
        book.chapters.create!(index: index, text: chapter)
      end
    end

    render json: book.attributes

  rescue => e
    logger.error e
    return nil
  end
end
