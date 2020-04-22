class Mail::BooksController < Mail::ApplicationController
  before_action :set_active_tab

  def index
    @books = GutenBook.all.page(params[:page]).per(50)
  end

  private

  def set_active_tab
    @active_tab = :books
  end
end
