class Search::BooksController < Search::ApplicationController
  def index
    books = @category[:id] == 'all' ? Book.all : Book.where(category_id: @category[:id])
    books = books.where(author_id: @author[:id]) if @author[:id] != 'all'
    @books = books.where.not(words_count: 0).sorted.order(:words_count).page(params[:page]).per(50)

    @meta_title = search_page_title
    @meta_description = search_page_description
    @meta_keywords = "#{@author[:name]},#{@category[:name]},#{@category[:title]}"
    @meta_canonical_url = root_path if @author[:id] == 'all' && @category[:id] == 'all'

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')} unless @author[:id] == 'all'
    category_name = @category[:id] == 'all' ? t(:all_works, scope: [:search, :controllers, :books]) : "#{@category[:title]}（#{@category[:name]}）"
    @breadcrumbs << { name: category_name }
  end


  def show
    @book = Book.find(params[:id])
    @author_books = Book.where.not(words_count: 0).where(author_id: @author[:id]).sorted.take(4)
    @category_books = Book.where(category_id: @category[:id]).sorted.take(4)

    @meta_title = show_page_title
    @meta_description = show_page_description
    @meta_keywords = [@book.title, @author[:name], @category[:title], @category[:name]].join(",")

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')}
    category_name = "#{@category[:title]}（#{@category[:name]}）"
    @breadcrumbs << { name: category_name, url: author_category_books_url(author_id: @author[:id], category_id: @category[:id]) }
    @breadcrumbs << { name: @book.title }
  end

  private

  def search_page_title
    author_name = @author[:id] == 'all' ? t(:original_site, scope: [:search, :controllers, :books]) : @author[:name]
    title = if @category[:id] == 'all'
              t :all_works_for, scope: [:search, :controllers, :books], author: author_name
            else
              t :category_works_for, scope: [:search, :controllers, :books], author: author_name, category: @category[:name], category_title: @category[:title]
            end
    title += t(:page_in, scope: [:search, :controllers, :books], page: params[:page]) if params[:page] && params[:page].to_i > 1
    title
  end

  def search_page_description
    book_count = @books.total_count.to_s(:delimited)
    if @category[:id] == 'all'
      t :description_all, scope: [:search, :controllers, :books], author: @author[:name], count: book_count
    else
      t :description_category, scope: [:search, :controllers, :books], author: @author[:name], count: book_count, category: @category[:name], category_title: @category[:title]
    end
  end

  def show_page_title
    t :title, scope: [:search, :controllers, :books, :show], author: @author[:name], title: @book.title, category: @category[:name], category_title: @category[:title]
  end

  def show_page_description
    t :description, scope: [:search, :controllers, :books, :show], author: @author[:name], title: @book.title, category: @category[:name], category_title: @category[:title], words_count: @book.words_count.to_s(:delimited)
    # "『#{@book.title}』は青空文庫で公開されている#{@author[:name]}の#{@category[:title]}作品。#{@book.words_count.to_s(:delimited)}文字で、おおよそ#{@category[:name]}で読むことができます。"
  end
end
