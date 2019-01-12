require 'open-uri'

class BooksController < ApplicationController
  def index
    @keyword = params[:keyword]
    @target = params[:target] || {work: true, author: true}
    @channels = current_user.channels if current_user

    # 検索実行時
    if @keyword.present?
      # 作品名検索
      if @target[:work] && !@target[:author]
        @results = Book.where("title LIKE ?", @keyword)
      # 著者名検索
      elsif @target[:author] && !@target[:work]
        @results = Book.where("author LIKE ?", @keyword)
      # 両方検索
      else
        @results = Book.where("author LIKE :q OR title LIKE :q", q: @keyword)
      end
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
