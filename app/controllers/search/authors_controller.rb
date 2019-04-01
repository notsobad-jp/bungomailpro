class Search::AuthorsController < Search::ApplicationController
  def index
    expires_now

    category_id = Category.find_by(id: params[:category_id]).try(:id) || 'all'
    @results = params[:author_name].present? ? Book.where("REPLACE(author, ' ', '') LIKE ?", "%#{params[:author_name].delete(' ')}%").pluck(:author_id, :author).to_h : {}
    return redirect_to author_category_books_path(author_id: @results.first[0], category_id: category_id) if @results.count == 1

    @meta_title = "「#{params[:author_name]}」の検索結果"
    @breadcrumbs << { name: '検索結果' }
  end
end
