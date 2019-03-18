class Search::CategoriesController < ApplicationController
  layout 'search/application'

  def index
    @category = params[:category]
    case @category
    when 'shortshort'
      @books = Book.where("chapters_count < ?", 30)
    when 'short'
      @books = Book.where(chapters_count: 30)
    when 'novelette'
      @books = Book.where(chapters_count: 60)
    when 'novel'
      @books = Book.where("chapters_count > ?", 60)
    end
    p @books.count
  end
end
