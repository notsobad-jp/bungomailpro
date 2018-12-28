class ChannelBooksController < ApplicationController
  before_action :require_login
  before_action :set_channel_with_books
  after_action :verify_authorized


  def create
    book = Book.find_or_scrape(book_id: params[:book_id], author_id: params[:author_id])
    channel = Channel.find_by(token: params[:id])

    if channel.add_book(book)
      # TODO: とりあえずチャネル追加後にchapterをscrapingする（全データ取得後に削除）
      book.delay.create_chapters if book.chapters_count == 0
      render json: { channel: channel.title, book: book.title }, status: 200
    else
      render json: nil, status: 500
    end
  end


  private
    def set_channel_with_books
      @channel = Channel.includes(:channel_books).find_by!(token: params[:id])
      authorize @channel
    end
end
