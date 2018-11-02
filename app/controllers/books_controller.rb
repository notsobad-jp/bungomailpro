require 'open-uri'
require 'nokogiri'

class BooksController < ApplicationController
  def scrape
    url = params[:url]
    match = url.match(/https?:\/\/www.aozora.gr.jp\/cards\/(\d+)\/files\/(\d+)_\d+\.html/).to_a
    return if !match

    book = Book.find_by(id: match[2])
    render json: book.attributes and return if book

    book_params = Book.parse_html(url)
    book = Book.create(book_params)
    render json: book.attributes
  end
end
