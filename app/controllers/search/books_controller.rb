class Search::BooksController < Search::ApplicationController
  include SearchHelper

  def index
    books = @category[:id] == 'all' ? Book.where.not(category_id: nil) : Book.where(category_id: @category[:id])
    books = @author[:id] == 'all' ? books.where.not(author_id: nil) : books.where(author_id: @author[:id])
    @books = books.where.not(words_count: 0).sorted.order(:words_count).page(params[:page]).per(50)

    @meta_title = search_page_title
    @meta_description = search_page_description
    @meta_keywords = "#{@author[:name]},#{@category[:name]},#{@category[:title]}"
    @meta_canonical_url = locale_root_url if @author[:id] == 'all' && @category[:id] == 'all'
    @meta_image = search_meta_image

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')} unless @author[:id] == 'all'
    category_name = @category[:id] == 'all' ? t(:all_works, scope: [:search, :controllers, :books]) : "#{@category[:title]}（#{@category[:name]}）"
    @breadcrumbs << { name: category_name }
  end


  def show
    @book = Book.find(params[:id])
    raise ActiveRecord::RecordNotFound if @book.words_count == 0  # locale間違いなどで wordsのない作品に来たら404
    @author = { id: @book.author_id, name: @book.author_name }

    @author_books = Book.where.not(words_count: 0).where(author_id: @author[:id]).sorted.take(4)
    @category_books = Book.where(category_id: @category[:id]).sorted.take(4)

    @meta_title = show_page_title
    @meta_description = show_page_description
    @meta_keywords = [@book.title, @author[:name], @category[:title], @category[:name]].join(",")
    @meta_image = show_meta_image

    @breadcrumbs << { name: @author[:name], url: author_category_books_url(author_id: @author[:id], category_id: 'all')}
    category_name = "#{@category[:title]}（#{@category[:name]}）"
    @breadcrumbs << { name: category_name, url: author_category_books_url(author_id: @author[:id], category_id: @category[:id]) }
    @breadcrumbs << { name: @book.title.truncate(50) }
  end

  private

  def search_page_title
    author_name = @author[:id] == 'all' ? t(:original_site, scope: [:search, :controllers, :books]) : @author[:name]
    title = if @category[:id] == 'all'
              t :all_works_for, scope: [:search, :controllers, :books], author: author_name
            else
              t :category_works_for, scope: [:search, :controllers, :books], author: author_name, category: @category[:name], category_title: @category[:title].capitalize
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

  def search_meta_image
    # トップページはデフォルトのOGP画像を使用
    return nil if @author[:id]=='all' && @category[:id]=='all'

    text = if @author[:id] == 'all'
      t :cloudinary_author_all, scope: [:search, :controllers, :books, :index], category: @category[:name], category_title: @category[:title]
    elsif @category[:id] == 'all'
      t :cloudinary_category_all, scope: [:search, :controllers, :books, :index], author: @author[:name]
    else
      t :cloudinary, scope: [:search, :controllers, :books, :index], author: @author[:name], category: @category[:name], category_title: @category[:title].capitalize
    end

    "https://res.cloudinary.com/notsobad/image/upload/y_-10,l_text:Roboto_80_line_spacing_15_text_align_center_font_antialias_good:#{text}/v1585631765/ogp_#{I18n.locale}.png"
  end

  def show_page_title
    t :title, scope: [:search, :controllers, :books, :show], author: @author[:name], title: @book.title, category: @category[:name], category_title: @category[:title]
  end

  def show_page_description
    t :description, scope: [:search, :controllers, :books, :show], author: @author[:name], title: @book.title, category: @category[:name], category_title: @category[:title], words_count: @book.words_count.to_s(:delimited)
  end

  def show_meta_image
    text = t :cloudinary, scope: [:search, :controllers, :books, :show], author: @author[:name], category: @category[:name], book: @book.title.truncate(30)
    "https://res.cloudinary.com/notsobad/image/upload/y_-10,l_text:Roboto_80_line_spacing_15_text_align_center_font_antialias_good:#{text}/v1585631765/ogp_#{I18n.locale}.png"
  end
end
