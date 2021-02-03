class PagesController < ApplicationController
  def show
    @page_title = page_titles[params[:page].to_sym]
    raise ActionController::RoutingError, request.url unless @page_title

    render params[:page]
  end

  private

  def page_titles
    {
      terms: '利用規約',
      privacy: 'プライバシーポリシー',
      tokushoho: '特定商取引法に基づく表示',
    }
  end
end
