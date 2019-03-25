class Search::BooksController < ApplicationController
  layout 'search/application'


  def search
    category_id = Category.find_by(id: params[:category_id]).try(:id) || 'all'

    author_id = Book.find_by(author: params[:author_name]).try(:author_id) || 'all'

    redirect_to books_search_author_path(id: author_id, category_id: category_id)
  end

  def index
    @categories = Category.all.order(:range_from)
    @category = Category.find_by(id: params[:category_id])

    book = Book.find_by(author_id: params[:id])
    @author = { id: book.try(:author_id) || 'all', name: book.try(:author) || 'すべての著者' }
    @authors = Book.limit(100).order('sum_access_count desc').group(:author, :author_id).sum(:access_count)

    query = Book.where(words_count: (@category.range_from..@category.range_to))
    query = query.where(author_id: @author[:id]) if @author[:id] != 'all'
    @books = query.order(access_count: :desc).order(:words_count).page(params[:page]).per(50)

    @breadcrumbs << { name: @author[:name], url: books_search_author_path(id: @author[:id], category_id: 'all')}
    @breadcrumbs << { name: @category.name }
  end

  def show
    @book = Book.find(params[:book_id])
  end
end
