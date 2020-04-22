class Mail::BooksController < Mail::ApplicationController
  before_action :set_book, only: [:show]
  before_action :set_active_tab

  def index
    @books = GutenBook.where.not(category_id: nil).where.not(author_id: nil).sorted.page(params[:page]).per(50)
    @category = GutenBook::CATEGORIES[:all]
  end

  def show
    @channel = current_user.default_channel
    @book_assignment = @channel.book_assignments.new(book_id: @book.id, book_type: @book.class.name)

    @categories = @book.class::CATEGORIES
    @category = @categories[@book.category_id.to_sym]
    @author = { id: @book.author_id, name: @book.author_name }
  end

  private

  def set_active_tab
    @active_tab = :books
  end

  def set_book
    book_class = params[:book_type] == 'aozora' ? AozoraBook : GutenBook
    @book = book_class&.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound unless @book&.category && @book&.author_id
  end
end
