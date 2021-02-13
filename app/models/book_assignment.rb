class BookAssignment < ApplicationRecord
  belongs_to :channel
  belongs_to :book, polymorphic: true
  has_many :chapters, -> { order(:send_at) }, dependent: :destroy
  has_many :delayed_jobs, through: :chapters, dependent: :destroy

  def create_chapters
    chapters = []
    contents = self.book.contents(count: self.count)
    send_at = self.start_at

    contents.each.with_index(1) do |content, index|
      title = "#{self.book.title}（#{index}/#{contents.count}）"
      chapters << {
        title: title,
        content: content,
        send_at: send_at,
        book_assignment_id: self.id
      }
      send_at += 1.day
    end
    Chapter.insert_all chapters
  end

  def twitter_short_url
    res = Bitly.call(path: 'shorten', params: { long_url: self.twitter_long_url })
    res["link"]
  end

  def twitter_long_url
    "https://twitter.com/intent/tweet?url=https%3A%2F%2Fbungomail.com%2F&hashtags=ブンゴウメール,青空文庫&text=#{start_at.month}月は%20%23#{book.author_name}%20%23#{book.title}%20を配信中！"
  end
end
