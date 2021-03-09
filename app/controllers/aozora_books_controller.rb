class AozoraBooksController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    @q = search_params
    @books = AozoraBook.search(@q).sorted.page(params[:page]).per 10
    @meta_title = '青空文庫の作品検索'
  end

  def show
    @book = AozoraBook.find(params[:id])
    @book_assignment = BookAssignment.new
    @q = search_params
    @meta_title = @book.title
    @breadcrumbs = [
      {text: '作品検索', link: aozora_books_path},
      {text: @book.title},
    ]
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:title, :author, words_count: [])
  end
end
