class Mail::PagesController < Mail::ApplicationController
  skip_before_action :require_login

  def lp
    render layout: false
  end

  def show
    @page_title = page_titles[params[:page].to_sym]
    raise ActionController::RoutingError, request.url unless @page_title

    @meta_title = @page_title
    @meta_description = "#{@page_title}のページです。"
    @meta_keywords = @page_title
    @breadcrumbs << { name: @page_title }

    render params[:page]
  end

  private

  def page_titles
    {
      terms: '利用規約',
      privacy: 'プライバシーポリシー',
      tokushoho: '特定商取引法に基づく表示'
    }
  end
end
