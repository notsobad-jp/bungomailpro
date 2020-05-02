class Mailing::AozoraBooksController < Mailing::BooksController

  private

  def set_book_and_book_class
    @book_class = AozoraBook
    @book = @book_class.find(params[:id]) if params[:id]
  end
end
