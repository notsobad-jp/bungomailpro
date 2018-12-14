class PagesController < ApplicationController
  def top
    @popular_authors = [
      { id: 148, name: '夏目漱石' },
      { id: 879, name: '芥川龍之介' },
      { id: 1779, name: '江戸川乱歩' },
      { id: 81, name: '宮沢賢治' }
    ]
    popular_book_ids = [127, 301, 45630, 789]
    @popular_books = Book.find(popular_book_ids)
  end
end
