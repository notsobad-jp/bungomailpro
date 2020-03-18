class Search::ApplicationController < ApplicationController
  layout 'search/layouts/application'
  around_action :switch_locale
  before_action :set_author_and_category, :set_cache_control, :set_meta_tags

  private

  def set_author_and_category
    @categories = Book::CATEGORIES
    @category = @categories[params[:category_id]&.to_sym || :all]

    @author = if ( params[:author_id] && book = Book.find_by(author_id: params[:author_id]))
      { id: book.author_id, name: book.author.split(',').first.delete(' ') }
    else
      { id: 'all', name: t(:all_authors, scope: [:search, :controllers, :application]) }
    end
    @authors = Book.popular_authors
  end

  def set_cache_control
    expires_in 1.month, public: true, must_revalidate: false
  end

  def set_meta_tags
    super
    @breadcrumbs << { name: 'TOP', url: root_path }
  end

  def switch_locale(&action)
    locale = request.subdomains.first == "en" ? :en : :ja
    Object.const_set "Book", Class.new(locale==:en ? GutenBook : AozoraBook)
    I18n.with_locale(locale, &action)
  end
end
