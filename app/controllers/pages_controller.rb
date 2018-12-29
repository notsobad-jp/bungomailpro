class PagesController < ApplicationController
  def top
    @popular_authors = [
      { id: 148, name: '夏目漱石' },
      { id: 879, name: '芥川龍之介' },
      { id: 1779, name: '江戸川乱歩' },
      { id: 81, name: '宮沢賢治' }
    ]
    @popular_books = ChannelBook.joins(:book).where("books.chapters_count <> 0").order(created_at: :desc).map(&:book).uniq.take(12)
  end
end
