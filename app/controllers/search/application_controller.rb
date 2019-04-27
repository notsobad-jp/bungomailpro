class Search::ApplicationController < ApplicationController
  layout 'search/application'
  before_action :set_author_and_category
  before_action :set_cache_control

  private

  def set_author_and_category
    @categories = Category.all.order(:range_from, :id)
    @category = Category.find_by(id: params[:category_id]) || Category.find('all')

    @author = if ( params[:author_id] && book = Book.find_by(author_id: params[:author_id]))
      { id: book.author_id, name: book.author.split(',').first.delete(' ') }
    else
      { id: 'all', name: 'すべての著者' }
    end
    @authors = Book.limit(100).order('sum_access_count desc').group(:author, :author_id).sum(:access_count)
  end

  def set_cache_control
    expires_in 1.month, public: true, must_revalidate: false
  end
end
