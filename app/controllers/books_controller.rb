require 'open-uri'
require 'nokogiri'

class BooksController < ApplicationController
  def scrape
    url = params[:url]
    aozora_id = url.match(/https?:\/\/www\.aozora\.gr\.jp\/cards\/\d+\/card(\d+)\.html/)[1]
    book = Book.find_by(aozora_id: aozora_id)
    render json: book.attributes if book

    charset = nil
    html = open(url) do |f|
      charset = f.charset
      f.read
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)

    title_data = {aozora_id: aozora_id}
    table = doc.xpath("//table[@summary='タイトルデータ']").first
    table.children.each do |node|
      next if node.name != 'tr'
      key = nil
      node.children.each do |td|
        if %w(作品名： 著者名：).include? td.inner_text
          key = (td.inner_text=='作品名：') ? 'title' : 'author'
          next
        end
        title_data[key] = td.inner_text.gsub(/\n|　/, '') if key
      end
    end
    book = Book.create(title_data)
    render json: book.attributes
  end
end
