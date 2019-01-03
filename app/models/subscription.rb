# == Schema Information
#
# Table name: subscriptions
#
#  id              :bigint(8)        not null, primary key
#  user_id         :bigint(8)        not null
#  channel_id      :bigint(8)        not null
#  default         :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  next_chapter_id :bigint(8)
#  last_chapter_id :bigint(8)
#  delivery_hour   :integer          default(8), not null
#  next_deliver_at :date
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel, counter_cache: :subscribers_count

  scope :sent_today, -> { where.not(last_chapter_id: nil).where(updated_at: Time.current.all_day) }

  before_create do
    # 自作channelで、かつuserがdefault_channelを持ってなければデフォルト指定する
    self.default = self.channel_owned? && self.user.subscriptions.find_by(default: true).blank?
  end

  def channel_owned?
    self.user_id == self.channel.user_id
  end

  def current_chapter
    # 当日分を配信済み OR 配信開始直後なら、next_chapterを返す
    no_delivery_for_today ? self.next_chapter : self.last_chapter
  end

  def next_channel_book
    self.channel_books.where(delivered: false).first
  end

  def next_deliver_at
    # 当日分を配信済み OR 配信開始直後なら、翌日日付にする
    date = no_delivery_for_today ? Time.current.tomorrow : Time.current
    date.change(hour: self.deliver_at)
  end

  def publish
    return if self.next_chapter_id
    ActiveRecord::Base.transaction do
      self.update!(next_chapter_id: next_channel_book.first_chapter.id)
      next_channel_book.update!(delivered: true)
    end
  end

  def publishable?
    # 現在配信中ではなくて、かつ配信待ちの本が存在する
    self.next_chapter_id.blank? && self.next_channel_book
  end

  def set_next_chapter
    # 同じ本で次のchapterが存在すればそれをセット
    next_chapter = self.next_chapter.next_chapter
    return self.update!(
      next_chapter_id: next_chapter.id,
      last_chapter_id: self.next_chapter_id
    ) if next_chapter

    # 次のchapterがなければ、次の本を探してindex:1でセット
    if next_channel_book
      ActiveRecord::Base.transaction do
        self.update!(
          next_chapter_id: next_channel_book.first_chapter.id,
          last_chapter_id: self.next_chapter_id
        )
        next_channel_book.update!(delivered: true)
      end
    # next_channel_bookもなければ配信停止状態にする
    else
      self.update!(
        next_chapter_id: nil,
        last_chapter_id: self.next_chapter_id
      )
    end
  end


  private
    # 当日分を配信済み OR 配信開始直後
    def no_delivery_for_today
      !self.last_chapter_id || Time.current > Time.current.change(hour: self.deliver_at)
    end
end
