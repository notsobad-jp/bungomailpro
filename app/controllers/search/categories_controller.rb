class Search::CategoriesController < ApplicationController
  layout 'search/application'

  def index
    @categories = Category.all.order(:range_from)
    @breadcrumbs << { name: 'カテゴリ' }
  end

  def show
    @categories = Category.all.order(:range_from)
    @category = Category.find_by(id: params[:id]) || Category.find('all')
    @books = Book.where(words_count: (@category.range_from..@category.range_to)).order(access_count: :desc).order(:words_count).page(params[:page]).per(50)

    @breadcrumbs << { name: 'カテゴリ', url: search_categories_path }
    @breadcrumbs << { name: @category.name }
  end
end
