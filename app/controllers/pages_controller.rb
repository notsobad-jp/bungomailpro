class PagesController < ApplicationController
  def top
    @popular_channels = Channel.where(status: 'public').take(3)
    @popular_authors = [
      { id: 148, name: '夏目漱石' },
      { id: 879, name: '芥川竜之介' },
      { id: 1779, name: '江戸川乱歩' },
      { id: 81, name: '宮沢賢治' }
    ]
    @popular_books = ChannelBook.includes(:book).order(created_at: :desc).map(&:book).uniq.take(12)
  end

  def terms
    @breadcrumbs << { name: '利用規約' }
  end

  def privacy
    @breadcrumbs << { name: 'プライバシーポリシー' }
  end

  def tokushoho
    @breadcrumbs << { name: '特商法' }
  end
end
