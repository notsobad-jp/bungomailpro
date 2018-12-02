require 'open-uri'

class BooksController < ApplicationController
  def index
    #FIXME: 仮の一覧表示
    @books = Book.order(created_at: :desc).limit(30)
    @default_channel_id = current_user.subscriptions.find_by(default: true).try(:channel_id) if current_user
    @default_channel_id ||= 1 #FIXME
  end

  def show
    @book = Book.find(params[:id])
    @default_channel_id = current_user.subscriptions.find_by(default: true).try(:channel_id) if current_user
    @default_channel_id ||= 1 #FIXME
  end

  def search
    url = params[:url]

    # 図書カードURLが来てたら、ファイルURLに変換
    if url.match(/https?:\/\/www\.aozora\.gr\.jp\/cards\/(\d+)\/card\d+.html/)
      url = Book.card_to_file_url(url)
    end

    match = url.match(/https?:\/\/www.aozora.gr.jp\/cards\/(\d+)\/files\/(\d+)_\d+\.html/).to_a
    if match.blank?
      flash[:error] = 'URLが正しくないようです。。XHTMLファイルか図書カードのURLを入力してください。'
      return redirect_to books_path
    end

    book = Book.find_by(id: match[2])
    return redirect_to book_path(book) if book

    book_params = Book.parse_html(url)
    text = book_params.delete(:text)
    book = Book.new(book_params)

    chapters = []
    Book.splited_text(text).each.with_index(1) do |chapter, index|
      chapters << Chapter.new(index: index, text: chapter)
    end
    book.chapters = chapters

    if book.save
      redirect_to book_path book
    else
      flash[:error] = '本が見つかりませんでした…。URLをもう一度確認してください。'
      redirect_to books_path
    end
  end
end
