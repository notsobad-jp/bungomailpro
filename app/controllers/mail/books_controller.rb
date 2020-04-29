class Mail::BooksController < Mail::ApplicationController
  before_action :set_book_and_book_class
  before_action :set_active_tab

  def index
    @search_params = search_params
    @channels = policy_scope(Channel)
    @books = @book_class.search(@search_params)&.page(params[:page])&.per(30)
  end

  def show
    @channels = policy_scope(Channel)
    @book_assignment = BookAssignment.new(book_id: @book.id, book_type: @book.class.name)
    @author = { id: @book.author_id, name: @book.author_name }
    render 'mail/books/show'
  end

  private

  def set_active_tab
    @active_tab = :books
  end

  def set_book_and_book_class
  end

  def search_params
    params.fetch(:q, {}).permit(:title, :author, :popularity, :category, :character_type, :juvenile)
  end
end
