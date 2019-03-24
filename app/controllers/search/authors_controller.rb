class Search::AuthorsController < ApplicationController
  layout 'search/application'

  def index
  end

  def show
    @categories = Category.all.order(:range_from)
    @category = Category.find_by(id: params[:category_id]) || Category.find('all')
    @books = Book.where(author_id: params[:id]).where(words_count: (@category.range_from..@category.range_to)).order(access_count: :desc).order(:words_count).page(params[:page]).per(50)

    book = @books.first || Book.find_by(author_id: params[:id])
    @author = { id: book.author_id, name: book.author }

    if @category
      @breadcrumbs << { name: @author[:name], url: search_author_path(@author[:id]) }
      @breadcrumbs << { name: @category.name }
    else
      @breadcrumbs << { name: @author[:name] }
    end
  end
end
