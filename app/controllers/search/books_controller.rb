class Search::BooksController < Search::ApplicationController
  before_action :set_amp_ready

  def index
    books = @category.id == 'all' ? Book.where(group: nil).includes(:category).all : @category.books
    books = books.where(author_id: @author[:id]) if @author[:id] != 'all'
    @books = books.where.not(words_count: 0).order(access_count: :desc).order(:words_count).page(params[:page]).per(50)

    @meta_title = search_page_title
    @meta_description = search_page_description
    @meta_keywords = "#{@author[:name]},#{@category.name}で読める,#{@category.title}"
    @meta_canonical_url = root_path if @author[:id] == 'all' && @category.id == 'all'

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')} unless @author[:id] == 'all'
    category_name = @category.id == 'all' ? '全作品' : "#{@category.title}（#{@category.name}）"
    @breadcrumbs << { name: category_name }

    respond_to do |format|
      format.html
      format.amp do
        lookup_context.formats = [:amp, :html] # .htmlのテンプレートも検索する
        render
      end
    end
  end


  def show
    @book = Book.includes(:category).find(params[:id])
    @author_books = Book.includes(:category).where.not(words_count: 0).where(author_id: @author[:id]).order(access_count: :desc).take(4)
    @category_books = @category.books.order(access_count: :desc).take(4)

    @meta_title = "#{@author[:name]}『#{@book.title}』 - #{@category.name}で読める#{@category.title}"
    @meta_description = "『#{@book.title}』は#{@author[:name]}の#{@category.title}作品。#{@book.words_count.to_s(:delimited)}文字で、おおよそ#{@category.name}で読むことができます。"
    @meta_keywords = [@book.title, @author[:name], @category.title, @category.name].join(",")

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')}
    category_name = "#{@category.title}（#{@category.name}）"
    @breadcrumbs << { name: category_name, url: author_category_books_url(author_id: @author[:id], category_id: @category.id) }
    @breadcrumbs << { name: @book.title }

    respond_to do |format|
      format.html
      format.amp do
        lookup_context.formats = [:amp, :html] # .htmlのテンプレートも検索する
        render
      end
    end
  end

  private

  def search_page_title
    author_name = @author[:id] == 'all' ? '青空文庫' : @author[:name]
    title = if @category.id == 'all'
              "#{author_name}の全作品"
            else
              "#{@category.name}で読める#{author_name}の#{@category.title}作品"
            end
    title += "（#{params[:page]}ページ目）" if params[:page] && params[:page].to_i > 1
    title
  end

  def search_page_description
    if @category.id == 'all'
      "青空文庫で公開されている#{@author[:name]}の全作品を、おすすめ人気順で表示しています。"
    else
      "青空文庫で公開されている#{@author[:name]}の作品の中で、おおよその読了目安時間が「#{@category.name}」の#{@category.title}#{@books.total_count.to_s(:delimited)}作品を、おすすめ人気順に表示しています。"
    end
  end

  def set_amp_ready
    @amp_ready = true
  end
end
