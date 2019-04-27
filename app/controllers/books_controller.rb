class BooksController < ApplicationController
  def index
    @keyword = params[:keyword]
    @target = params[:target] || { work: true, author: true }
    @length = params[:length] || { lt_one: true, one: true, two: true, three: true, gt_four: true }
    @channels = current_user.channels if current_user

    # 検索実行時
    if @keyword.present?
      # キーワード検索
      query = []
      query << "replace(title, ' ', '') LIKE :q" if @target[:work]
      query << "replace(author, ' ', '') LIKE :q" if @target[:author]
      @results = Book.where(group: nil).where(query.join(' OR '), q: "%#{@keyword.delete(' ')}%")

      # 配信期間検索
      query = []
      query << "chapters_count < 30" if @length["lt_one"]
      query << "chapters_count = 30" if @length["one"]
      query << "chapters_count = 60" if @length["two"]
      query << "chapters_count = 90" if @length["three"]
      query << "chapters_count > 90" if @length["gt_four"]
      @results = @results.where(query.join(' OR '))

      @results = @results.page params[:page]
      @breadcrumbs << { name: '作品検索', url: books_path }
      @breadcrumbs << { name: @keyword }
    else
      @breadcrumbs << { name: '作品検索' }
    end
  end
end
