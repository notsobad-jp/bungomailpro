class AozoraBooksController < ApplicationController
  skip_before_action :require_login, only: [:index, :show]

  def index
    @meta_title = '青空文庫の作品検索'
  end

  def show
    @book = AozoraBook.find(params[:id])
    @meta_title = @book.title
  end
end
