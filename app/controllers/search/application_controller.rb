class Search::ApplicationController < ApplicationController
  layout 'search/layouts/application'
  before_action :set_locale, :set_author_and_category, :set_cache_control, :set_meta_tags

  private

  def set_author_and_category
    @categories = Book::CATEGORIES
    @category = @categories[params[:category_id]&.to_sym || :all]

    @author = if ( params[:author_id] && book = Book.find_by(author_id: params[:author_id]))
      { id: book.author_id, name: book.author.split(',').first.delete(' ') }
    else
      { id: 'all', name: 'すべての著者' }
    end
    @authors = Book.popular_authors
  end

  def set_cache_control
    expires_in 1.month, public: true, must_revalidate: false
  end

  def set_meta_tags
    super
    @breadcrumbs << { name: 'TOP', url: root_url }
  end

  def set_locale
    I18n.locale = request.subdomain.include?("en") ? :en : :ja
    # enのときはBookでGutenBook、それ以外はAozoraBookを返す
    Object.const_set "Book", Class.new(I18n.locale==:en ? GutenBook : AozoraBook)
  end
end
