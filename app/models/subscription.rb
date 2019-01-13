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
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel, counter_cache: :subscribers_count
  belongs_to :current_book, class_name: 'Book', foreign_key: 'current_book_id', optional: true
  belongs_to :next_chapter, class_name: 'Chapter', foreign_key: [:current_book_id, :next_chapter_index], optional: true

  validates :delivery_hour, presence: true


  def current_channel_book
    ChannelBook.find_by(channel_id: self.channel_id, book_id: self.current_book_id)
  end


  def current_chapter
    return if !self.next_chapter  # 配信完了状態ではnilを返す

    # 配信時間を過ぎてればnext_chapterを返す
    if Time.current > Time.current.change(hour: self.delivery_hour)
      self.next_chapter
    # それ以前ならprev_chapter（配信予約中は存在しないので、next_chapterを返す）
    else
      self.prev_chapter || self.next_chapter
    end
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

    # 同じ本で次のchapterが存在すればそれをセット
    if next_chapter = current_chapter.next
      self.update!(
        next_chapter_index: next_chapter.index,
        next_delivery_date: Time.zone.tomorrow
      )
    # 次のchapterがなければ、次の本を探してindex:1でセット
    elsif next_channel_book = self.current_channel_book.next
      self.update!(
        next_chapter_index: 1,
        current_book_id: next_channel_book.book_id,
        next_delivery_date: Time.zone.tomorrow
      )
    # next_channel_bookもなければ配信停止状態にする
    else
      self.update!(
        next_chapter_index: nil,
        current_book_id: nil,
        next_delivery_date: nil
      )
    end
    Logger.new(STDOUT).info "[CHAPTER SET] sub:#{self.id}, from:#{current_chapter.book_id}-#{current_chapter.index}, to:#{next_chapter.try(:book_id)}-#{next_chapter.try(:index)}"
  end


  # 最初の本の最初のchapter配信前
  def not_started?
    self.next_chapter_index == 1 && self.current_channel_book.index == 1
  end


  private
    def current_book_index
      self.current_channel_book.try(:index) || 0
    end
end
