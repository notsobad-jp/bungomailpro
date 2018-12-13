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
    end
  end


  # 図書カード OR XHTMLのURLを受け取って、@bookを返す（存在しなければscrape）
  def url
    url = params[:url]
    match = url.match(/https?:\/\/www\.aozora\.gr\.jp\/cards\/(\d+)\/card(\d+).html/)
    match = url.match(/https?:\/\/www.aozora.gr.jp\/cards\/(\d+)\/files\/(\d+)_(\d+)\.html/) if !match

    if match
      render json: Book.find_or_scrape(author_id: match[1].to_i, book_id: match[2].to_i).attributes, status: 200
    else
      render json: nil, status: 500
    end
  end
end
