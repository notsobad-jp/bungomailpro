class Search::BooksController < Search::ApplicationController
  def index
    books = @category.id == 'all' ? Book.includes(:category).all : @category.books
    books = books.where(author_id: @author[:id]) if @author[:id] != 'all'
    @books = books.where.not(words_count: 0).order(access_count: :desc).order(:words_count).page(params[:page]).per(50)

    @meta_title = search_page_title(author: @author, category: @category)
    @meta_description = "#{@meta_title}です。" unless @author[:id] == 'all' && @category.id == 'all'
    @meta_keywords = "#{@author[:name]},#{@category.name}で読める,#{@category.title}"
    @meta_canonical_url = root_path if @author[:id] == 'all' && @category.id == 'all'

    @breadcrumbs << { name: @author[:name], url: author_category_books_path(author_id: @author[:id], category_id: 'all')} unless @author[:id] == 'all'
    category_name = @category.id == 'all' ? '全作品' : "#{@category.title}（#{@category.name}）"
    @breadcrumbs << { name: category_name }
  end


  def show
    @book = Book.includes(:category).find(params[:id])
    @author_books = Book.includes(:category).where(author_id: @author[:id]).order(access_count: :desc).take(4)
    @category_books = @category.books.order(access_count: :desc).take(4)

    @meta_title = "#{@author[:name]}『#{@book.title}』 - #{@category.name}で読める#{@category.title}"
    @meta_description = "『#{@book.title}』は#{@author[:name]}の#{@category.title}作品。#{@book.words_count.to_s(:delimited)}文字で、おおよそ#{@category.name}で読むことができます。"
    @meta_keywords = [@book.title, @author[:name], @category.title, @category.name].join(",")

    @breadcrumbs << { name: @author[:name], url: author_category_books_path(author_id: @author[:id], category_id: 'all')}
    category_name = "#{@category.title}（#{@category.name}）"
    @breadcrumbs << { name: category_name, url: author_category_books_path(author_id: @author[:id], category_id: @category.id) }
    @breadcrumbs << { name: @book.title }
  end

  private

  def search_page_title(author:, category:)
    author_name = author[:id] == 'all' ? '青空文庫' : author[:name]
    if category.id == 'all'
      "#{author_name}の全作品"
    else
      "#{category.name}で読める#{author_name}の#{category.title}作品"
    end
  end
end
