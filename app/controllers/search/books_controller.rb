class Search::BooksController < ApplicationController
  layout 'search/application'

  def show
    @book = Book.find(params[:id])
  end
end
