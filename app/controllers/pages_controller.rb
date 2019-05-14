class PagesController < ApplicationController
  def top
    @streaming_channels = Channel.find([Channel::BUSINESSMODEL_ID, Channel::ALTEREGO_ID, Channel::URABANGUMI_ID])
    @popular_authors = [
      { id: 148, name: '夏目漱石' },
      { id: 879, name: '芥川竜之介' },
      { id: 1779, name: '江戸川乱歩' },
      { id: 81, name: '宮沢賢治' }
    ]
    @popular_books = ChannelBook.includes(:book).order(created_at: :desc).map(&:book).uniq.take(12)
  end

  def lp
    render layout: false
  end

  def index
    @pages = page_titles
    @breadcrumbs << { name: 'ドキュメント' }
  end

  def show
    @page_title = page_titles[params[:page].to_sym]
    raise ActionController::RoutingError, request.url unless @page_title

    @meta_title = @page_title
    @meta_description = "#{@page_title}のページです。"
    @meta_keywords = @page_title
    @breadcrumbs << { name: 'ドキュメント', url: pages_path }
    @breadcrumbs << { name: @page_title }

    render params[:page]
  end

  private

  def page_titles
    {
      about: 'ブンゴウメールとは？',
      plan: '料金プラン',
      faq: 'よくある質問',
      terms: '利用規約',
      privacy: 'プライバシーポリシー',
      tokushoho: '特定商取引法に基づく表示'
    }
  end
end
