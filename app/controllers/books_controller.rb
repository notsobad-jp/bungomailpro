require 'open-uri'

class BooksController < ApplicationController
  before_action :require_login, only: [:scrape]

  def index
    #FIXME: 仮の一覧表示
    @books = Book.all
  end

  def show
    @book = Book.find(params[:id])
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
    book = Book.new(book_params)

    chapters = []
    Book.splited_text(text).each.with_index(1) do |chapter, index|
      chapters << Chapter.new(index: index, text: chapter)
    end
    book.chapters = chapters

    if book.save
      render json: book.attributes
    else
      p book.errors
      return nil
    end
  end
end
