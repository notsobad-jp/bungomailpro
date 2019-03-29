class Search::BooksController < ApplicationController
  layout 'search/application'
  before_action :set_author_and_category, except: :search


  def search
    category_id = Category.find_by(id: params[:category_id]).try(:id) || 'all'

    if params[:author_name].present?
      authors = Book.group(:author, :author_id).where("REPLACE(author, ' ', '') LIKE ?", "%#{params[:author_name].delete(' ')}%").count
      author_id = (authors.count > 0) ? authors.first[0][1] : 'all'

      if authors.count == 0
        aozora_link = view_context.link_to '青空文庫', 'https://www.aozora.gr.jp/index_pages/person_all.html', target: '_blank'
        flash[:warning] = "著者が見つかりませんでした…。著者名の表記は#{aozora_link}に準拠していますので、漢字などの表記違いがないかご確認ください。また現在ゾラサーチでは、著作権が存続している著者は取り扱っておりません。"
      elsif authors.count > 1
        authors_list = authors.take(10).map do |author_data, count|
          author_link = view_context.link_to author_data[0], author_category_books_path(author_id: author_data[1], category_id: category_id)
          "<li>#{author_link}</li>"
        end
        authors_list << "<li>...</li>" if authors.count > 10
        flash[:warning] = "#{authors.count}件の著者が該当しました。お探しの著者でなかった場合は、キーワードを変えて絞り込んでください。<ul>#{authors_list.join('')}</ul>"
      end
    else
      author_id = 'all'
    end

    redirect_to author_category_books_path(author_id: author_id, category_id: category_id)
  end


  def index
    query = Book.where(words_count: (@category.range_from..@category.range_to))
    query = query.where(author_id: @author[:id]) if @author[:id] != 'all'
    @books = query.order(access_count: :desc).order(:words_count).page(params[:page]).per(50)

    @meta_title = view_context.search_page_title(author: @author, category: @category)
    @meta_description = "#{@meta_title}です。" unless @author[:id] == 'all' && @category.id == 'all'
    @meta_keywords = "#{@author[:name]},#{@category.name}で読める,#{view_context.category_title(@category)}"
    @meta_canonical_url = root_path if @author[:id] == 'all' && @category.id == 'all'

    @breadcrumbs << { name: @author[:name], url: author_category_books_path(author_id: @author[:id], category_id: 'all')} unless @author[:id] == 'all'
    category_name = @category.id == 'all' ? '全作品' : "#{view_context.category_title(@category)}（#{@category.name}）"
    @breadcrumbs << { name: category_name }
  end


  def show
    @book = Book.find(params[:id])
    @author_books = Book.where(author_id: @author[:id]).order(access_count: :desc).take(4)
    @category_books = Book.where(words_count: @category.range_from..@category.range_to).order(access_count: :desc).take(4)

    @meta_title = "#{@author[:name]}『#{@book.title}』 - #{@category.name}で読める#{view_context.category_title(@category)}"
    @meta_description = "『#{@book.title}』は#{@author[:name]}の#{view_context.category_title(@category)}作品。#{@book.words_count.to_s(:delimited)}文字で、おおよそ#{@category.name}で読むことができます。"
    @meta_keywords = [@book.title, @author[:name], view_context.category_title(@category), @category.name].join(",")

    @breadcrumbs << { name: @author[:name], url: author_category_books_path(author_id: @author[:id], category_id: 'all')}
    category_name = "#{view_context.category_title(@category)}（#{@category.name}）"
    @breadcrumbs << { name: category_name, url: author_category_books_path(author_id: @author[:id], category_id: @category.id) }
    @breadcrumbs << { name: @book.title }
  end


  private

  def set_author_and_category
    @categories = Category.all.order(:range_from)
    @category = Category.find_by(id: params[:category_id]) || Category.find('all')

    @author = if (book = Book.find_by(author_id: params[:author_id]))
      { id: book.author_id, name: book.author.split(',').first }
    else
      { id: 'all', name: 'すべての著者' }
    end
    @authors = Book.limit(100).order('sum_access_count desc').group(:author, :author_id).sum(:access_count)
  end
end
