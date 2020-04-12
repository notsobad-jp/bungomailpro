class Search::PagesController < Search::ApplicationController
  def about
    @page_title = t :about, scope: [:search, :controllers, :pages]

    @meta_title = @page_title
    @meta_description = @page_title
    @meta_keywords = @page_title
    @meta_canonical_url = url_for(juvenile: nil)
    @breadcrumbs << { name: @page_title }

    render 'about'
  end
end
