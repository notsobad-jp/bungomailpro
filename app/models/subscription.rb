# == Schema Information
#
# Table name: subscriptions
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)        not null
#  channel_id         :bigint(8)        not null
#  current_book_id    :bigint(8)
#  next_chapter_index :integer
#  delivery_hour      :integer          default(8), not null
#  next_delivery_date :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  token              :string           not null
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel, counter_cache: :subscribers_count
  belongs_to :current_book, class_name: 'Book', foreign_key: 'current_book_id', optional: true
  belongs_to :next_chapter, class_name: 'Chapter', foreign_key: [:current_book_id, :next_chapter_index], optional: true
  has_many :feeds, -> { order(delivered_at: :desc) },  dependent: :destroy

  validates :delivery_hour, presence: true
  validates_associated :user

  before_create do
    self.token = SecureRandom.hex(10)
  end


  def create_feed
    self.feeds.create!(
      book_id: self.current_book_id,
      index: self.next_chapter_index,
      delivered_at: self.next_deliver_at
    )
  end


  def current_channel_book
    ChannelBook.find_by(channel_id: self.channel_id, book_id: self.current_book_id)
  end


  def current_chapter
    return if !self.next_chapter  # 配信完了状態ではnilを返す
    return self.next_chapter if self.not_started?   # 配信開始前は常にnext_chapterを返す

    # 配信時間を過ぎてればnext_chapter、それ以前ならprev_chapterを返す
    Time.current > Time.current.change(hour: self.delivery_hour) ? self.next_chapter : self.prev_chapter
  end


  # メール送信して、RSSフィードに追加して、配信情報を更新する
  ## TODO: メール配信でコケたらその後の処理も止まるけど、途中でコケるとメールだけ送られてしまう問題
  def deliver_and_update
    return if !self.current_book_id  # もし配信終了してるときはスキップ（2月で2回配信するときに配信終了状態で来る可能性がある）
    return if self.next_delivery_date != Time.zone.today  # 配信日が今日じゃなければスキップ（このあとの処理を実行する前に2回処理予約されると重複処理される可能性がある）

    # 有料ユーザーのみメール配信
    UserMailer.with(subscription: self).chapter_email.deliver_now if self.user.pro?  # deliver_nowだけどSendGrid側で予約配信するのでまだ送られない

    # RSSフィードと次の配信情報の更新（無料ユーザーも）
    self.create_feed
    self.set_next_chapter
  end


  def finished?
    !self.current_book_id
  end


  def finished_books
    self.channel.channel_books.where("index < ?", current_book_index).map(&:book)
  end


  def next_deliver_at
    return if !self.next_delivery_date
    Time.zone.parse(self.next_delivery_date.to_s).change(hour: self.delivery_hour)
  end


  def prev_chapter
    return if !self.next_chapter_index

    # 同じ本で前のchapterが存在すればそれを返す
    if self.next_chapter_index > 1
      return self.next_chapter.prev
    end

    # なければ前の本の最後のchapterを返す
    if self.current_channel_book.index > 1
      prev_channel_book = self.current_channel_book.prev
      return prev_channel_book.book.chapters.last
    end

    # 前の本もない場合（＝最初の本の最初の配信前）；prevなし
  end


  def scheduled_books
    self.channel.channel_books.where("index > ?", current_book_index).map(&:book)
  end


  def set_next_chapter
    current_chapter = self.next_chapter
    return if !current_chapter

    # 次回配信は基本翌日。翌日が31日だった場合のみ飛ばしてその次の日(1日)をセット
    tomorrow = Time.zone.tomorrow
    next_delivery_date = (tomorrow.day == 31) ? tomorrow.tomorrow : tomorrow

    # 同じ本で次のchapterが存在すればそれをセット
    if next_chapter = current_chapter.next
      self.update!(
        next_chapter_index: next_chapter.index,
        next_delivery_date: next_delivery_date
      )
    # 次のchapterがなければ、次の本を探してindex:1でセット
    elsif next_channel_book = self.current_channel_book.next
      self.update!(
        next_chapter_index: 1,
        current_book_id: next_channel_book.book_id,
        next_delivery_date: next_delivery_date
      )
    # next_channel_bookもなければ配信停止状態にする
    else
      self.update!(
        next_chapter_index: nil,
        current_book_id: nil,
        next_delivery_date: nil
      )
    end
    logger.info "[CHAPTER SET] sub:#{self.id}, from:#{current_chapter.book_id}-#{current_chapter.index}, to:#{next_chapter.try(:book_id)}-#{next_chapter.try(:index)}"
  end


  # 最初の本の最初のchapter配信前
  def not_started?
    self.next_chapter_index == 1 && self.current_channel_book.index == 1
  end


  private
    # 配信終了（current_channel_bookがnil）の場合は最大値を返す
    def current_book_index
      self.current_channel_book.try(:index) || Float::MAX
    end
end
