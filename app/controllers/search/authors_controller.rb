class Search::AuthorsController < Search::ApplicationController
  def index
    expires_now

    @results = params[:author_name].present? ? Book.where("REPLACE(author, ' ', '') LIKE ?", "%#{Book.author_search_name(params[:author_name])}%").pluck(:author_id, :author).to_h : {}
    return redirect_to author_category_books_path(author_id: @results.first[0], category_id: params[:category_id]) if @results.count == 1

    @meta_title = t(:search_result_for, scope: [:search, :controllers, :authors], author: params[:author_name])
    @breadcrumbs << { name: t(:search_result, scope: [:search, :controllers, :authors] ) }
  end
end
