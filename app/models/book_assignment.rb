class BookAssignment < ApplicationRecord
  belongs_to :channel
  belongs_to :book, polymorphic: true
  has_many :chapters, -> { order(:delivery_date) }, dependent: :destroy
  has_many :delayed_jobs, through: :chapters, dependent: :destroy

  before_create do
    self.twitter_share_url = self.twitter_short_url unless Rails.env.test?
  end

  def create_chapters
    chapters = []
    contents = self.book.contents(count: self.count)
    delivery_date = self.start_date

    contents.each.with_index(1) do |content, index|
      title = "#{self.book.title}（#{index}/#{contents.count}）"
      chapters << {
        title: title,
        content: content,
        delivery_date: delivery_date,
        book_assignment_id: self.id
      }
      delivery_date += 1.day
    end
    Chapter.insert_all chapters
  end

  def twitter_short_url
    begin
      Bitly.call(path: 'shorten', params: { long_url: self.twitter_long_url })
    rescue => e
      logger.error "[Error] Bitly API failed: #{e}"
    end
  end

  def twitter_long_url
    "https://twitter.com/intent/tweet?url=https%3A%2F%2Fbungomail.com%2F&hashtags=ブンゴウメール,青空文庫&text=#{start_date.month}月は%20%23#{book.author_name}%20%23#{book.title}%20を配信中！"
  end
end
