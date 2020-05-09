class Mailing::PagesController < Mailing::ApplicationController
  skip_before_action :require_login

  def lp
    render layout: false
  end

  def new_lp
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

  def dogramagra
    @page_title = "ドグラ・マグラ365日配信チャレンジ"

    @meta_title = @page_title
    @meta_description = "夢野久作『ドグラ・マグラ』を、365日かけて毎日メールで少しずつ配信します。"
    @meta_keywords = @page_title
    @breadcrumbs << { name: @page_title }
    @meta_image = "https://bungomail.com/assets/images/campaigns/dogramagra.png"
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
