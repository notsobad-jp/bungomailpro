class Search::PagesController < Search::ApplicationController
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
      about: t(:about, scope: [:search, :controllers, :pages])
    }
  end
end
