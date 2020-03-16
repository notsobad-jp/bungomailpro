class Search::BooksController < Search::ApplicationController
  def index
    books = @category[:id] == 'all' ? Book.all : Book.where(category_id: @category[:id])
    books = books.where(author_id: @author[:id]) if @author[:id] != 'all'
    @books = books.where.not(words_count: 0).sorted.order(:words_count).page(params[:page]).per(50)

    @meta_title = search_page_title
    @meta_description = search_page_description
    @meta_keywords = "#{@author[:name]},#{@category[:name]}で読める,#{@category[:title]}"
    @meta_canonical_url = root_path if @author[:id] == 'all' && @category[:id] == 'all'

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')} unless @author[:id] == 'all'
    category_name = @category[:id] == 'all' ? '全作品' : "#{@category[:title]}（#{@category[:name]}）"
    @breadcrumbs << { name: category_name }
  end


  def show
    @book = Book.find(params[:id])
    @author_books = Book.where.not(words_count: 0).where(author_id: @author[:id]).sorted.take(4)
    @category_books = Book.where(category_id: @category[:id]).sorted.take(4)

    @meta_title = "#{@author[:name]}『#{@book.title}』 - #{@category[:name]}で読める#{@category[:title]}"
    @meta_description = "『#{@book.title}』は青空文庫で公開されている#{@author[:name]}の#{@category[:title]}作品。#{@book.words_count.to_s(:delimited)}文字で、おおよそ#{@category[:name]}で読むことができます。"
    @meta_keywords = [@book.title, @author[:name], @category[:title], @category[:name]].join(",")

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')}
    category_name = "#{@category[:title]}（#{@category[:name]}）"
    @breadcrumbs << { name: category_name, url: author_category_books_url(author_id: @author[:id], category_id: @category[:id]) }
    @breadcrumbs << { name: @book.title }
  end

  private

  def search_page_title
    author_name = @author[:id] == 'all' ? '青空文庫' : @author[:name]
    title = if @category[:id] == 'all'
              "#{author_name}の全作品"
            else
              "#{@category[:name]}で読める#{author_name}の#{@category[:title]}作品"
            end
    title += "（#{params[:page]}ページ目）" if params[:page] && params[:page].to_i > 1
    title
  end

  def search_page_description
    book_count = @books.total_count.to_s(:delimited)
    if @category[:id] == 'all'
      "青空文庫で公開されている#{@author[:name]}の全作品#{book_count}篇を、おすすめ人気順で表示しています。"
    else
      "青空文庫で公開されている#{@author[:name]}の作品の中で、おおよその読了目安時間が「#{@category[:name]}」の#{@category[:title]}#{book_count}作品を、おすすめ人気順に表示しています。"
    end
  end
end
