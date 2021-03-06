class BookAssignment < ApplicationRecord
  belongs_to :channel
  belongs_to :book, polymorphic: true
  has_many :feeds, dependent: :destroy
  has_many :delayed_jobs, through: :feeds

  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_comes_after_start_date
  validate :delivery_period_should_not_overlap # 同一チャネルで期間が重複するレコードが存在すればinvalid

  before_create do
    # self.twitter_share_url = self.twitter_short_url
  end


  def count
    (end_date - start_date) + 1
  end

  def create_and_schedule_feeds
    feed_ids = create_feeds
    Feed.find(feed_ids).map(&:schedule)
  end

  def create_feeds
    feeds = []
    contents = self.book.contents(count: count)
    delivery_date = self.start_date

    contents.each.with_index(1) do |content, index|
      title = "#{self.book.title}（#{index}/#{contents.count}）"
      feeds << {
        title: title,
        content: content,
        delivery_date: delivery_date,
        book_assignment_id: self.id
      }
      delivery_date += 1.day
    end
    res = Feed.insert_all feeds
    res.rows.flatten  # 作成したfeedのid一覧を配列で返す
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


  private

  # 同一チャネルで期間が重複するレコードが存在すればinvalid
  def delivery_period_should_not_overlap
    overlapping = BookAssignment.where.not(id: id).where(channel_id: channel_id).where("end_date > ? and ? > start_date", start_date, end_date)
    errors.add(:start_date, "配信期間が重複しています") if overlapping.present?
  end

  def end_date_comes_after_start_date
    errors.add(:end_date, "配信終了日は開始日より後に設定してください") if end_date && end_date <= start_date
  end
end
