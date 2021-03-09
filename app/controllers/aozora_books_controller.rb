class AozoraBooksController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    @meta_title = '青空文庫の作品検索'
    @q = search_params
    @books = AozoraBook.search(@q).sorted.page(params[:page]).per 10
  end

  def show
    @book = AozoraBook.find(params[:id])
    @book_assignment = BookAssignment.new
    @meta_title = @book.title
    @breadcrumbs = [
      {text: '作品検索', link: aozora_books_path},
      {text: @book.title},
    ]
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:title, :author)
  end
end
