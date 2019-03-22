class Search::AuthorsController < ApplicationController
  layout 'search/application'

  def index
  end

  def show
    @categories = Category.all.order(:range_from)
    @category = Category.find_by(id: params[:category_id])
    query = Book.where(author_id: params[:id])
    query = query.where(words_count: (@category.range_from..@category.range_to)) if @category
    @books = query.order(access_count: :desc).order(:words_count).page params[:page]
    @author = { id: @books.first.author_id, name: @books.first.author }

    if @category
      @breadcrumbs << { name: @books.first.author, url: search_author_path(@books.first.author_id) }
      @breadcrumbs << { name: @category.name }
    else
      @breadcrumbs << { name: @books.first.author }
    end
  end
end
