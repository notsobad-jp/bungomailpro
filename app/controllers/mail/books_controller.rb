class Mail::BooksController < Mail::ApplicationController
  before_action :set_book_and_book_class
  before_action :set_active_tab

  def index
    @books = @book_class.where.not(category_id: nil).where.not(author_id: nil).sorted.page(params[:page]).per(50)
    @category = @book_class::CATEGORIES[:all]
  end

  def show
    @channel = current_user.default_channel
    @book_assignment = BookAssignment.new(book_id: @book.id, book_type: @book.class.name)

    @categories = @book.class::CATEGORIES
    @category = @categories[@book.category_id.to_sym]
    @author = { id: @book.author_id, name: @book.author_name }

    render 'mail/books/show'
  end

  private

  def set_active_tab
    @active_tab = :books
  end

  def set_book_and_book_class
  end
end
