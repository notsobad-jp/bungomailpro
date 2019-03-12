class PagesController < ApplicationController
  def top
    # @streaming_channels = Channel.where(status: 'streaming').order(created_at: :desc).take(3)
    @streaming_channels = Channel.where(status: 'streaming').order(created_at: :asc).take(1)
    @popular_channels = Channel.where(status: 'public').order(created_at: :desc).take(3)
    @popular_authors = [
      { id: 148, name: '夏目漱石' },
      { id: 879, name: '芥川竜之介' },
      { id: 1779, name: '江戸川乱歩' },
      { id: 81, name: '宮沢賢治' }
    ]
    @popular_books = ChannelBook.includes(:book).order(created_at: :desc).map(&:book).uniq.take(12)
  end

  def show
    page_titles = {
      faq: 'よくある質問',
      terms: '利用規約',
      privacy: 'プライバシーポリシー',
      tokushoho: '特定商取引法に基づく表示',
    }
    @page_title = page_titles[params[:page].to_sym]

    @meta_title = @page_title
    @meta_description = "#{@page_title}のページです。"
    @meta_keywords = @page_title
    @breadcrumbs << { name: @page_title }

    render params[:page]
  end
end
