class BooksController < ApplicationController
  def index
    @keyword = params[:keyword]
    @target = params[:target] || {work: true, author: true}
    @channels = current_user.channels if current_user

    # 検索実行時
    if @keyword.present?
      query = []
      query << "replace(title, ' ', '') LIKE :q" if @target[:work]
      query << "replace(author, ' ', '') LIKE :q" if @target[:author]
      @results = Book.where(query.join(" OR "), q: "%#{@keyword.gsub(' ', '')}%")
      @results = @results.page params[:page]

      @breadcrumbs << {name: '作品検索', url: books_path}
      @breadcrumbs << {name: @keyword}
    else
      @breadcrumbs << {name: '作品検索'}
    end
  end
end
