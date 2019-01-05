# == Schema Information
#
# Table name: subscriptions
#
#  id                    :bigint(8)        not null, primary key
#  user_id               :bigint(8)        not null
#  channel_id            :bigint(8)        not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  default               :boolean          default(FALSE), not null
#  current_book_id       :bigint(8)
#  current_chapter_index :integer
#  delivery_hour         :integer          default(8), not null
#  next_delivery_date    :date
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel, counter_cache: :subscribers_count
  belongs_to :current_book, class_name: 'Book', foreign_key: 'current_book_id', optional: true
  belongs_to :current_chapter, class_name: 'Chapter', foreign_key: [:current_book_id, :current_chapter_index], optional: true
  belongs_to :current_channel_book, class_name: 'ChannelBook', foreign_key: [:channel_id, :current_book_id], optional: true

  validates :delivery_hour, presence: true


  def current_chapter
    # 当日分を配信済み OR 配信開始前なら、next_chapterを返す
    no_delivery_for_today ? self.next_chapter : self.last_chapter
  end

  def next_book
    self.channel.next_book(self.next_chapter.book_id)
  end

  def next_deliver_at
    return if !self.next_delivery_date
    Time.zone.parse(self.next_delivery_date.to_s).change(hour: self.delivery_hour)
  end

  def set_next_chapter
    # 同じ本で次のchapterが存在すればそれをセット
    next_chapter = self.next_chapter.next_chapter
    return self.update!(
      next_chapter_id: next_chapter.id,
      last_chapter_id: self.next_chapter_id,
      next_deliver_at: Time.zone.tomorrow
    ) if next_chapter

    # 次のchapterがなければ、次の本を探してindex:1でセット
    if self.next_book
      self.update!(
        next_chapter_id: self.next_book.first_chapter.id,
        last_chapter_id: self.next_chapter_id,
        next_deliver_at: Time.zone.tomorrow
      )
    # next_channel_bookもなければ配信停止状態にする
    else
      self.update!(
        next_chapter_id: nil,
        last_chapter_id: self.next_chapter_id,
        next_deliver_at: nil
      )
    end
  end


  private
    # 当日分を配信済み OR 配信開始前
    def no_delivery_for_today
      !self.last_chapter_id || Time.current > Time.current.change(hour: self.deliver_at)
    end
end
