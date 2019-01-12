require 'open-uri'

class BooksController < ApplicationController
  def index
    @keyword = params[:keyword]
    @target = params[:target] || {work: true, author: true}
    @channels = current_user.channels if current_user

    # 検索実行時
    if @keyword.present?
      query = []
      query << "replace(title, ' ', '') LIKE :q" if @target[:work]
      query << "replace(autor, ' ', '') LIKE :q" if @target[:author]
      @results = Book.where(query.join(" OR "), q: "%#{@keyword.gsub(' ', '')}%")
      @results = @results.page params[:page]
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
