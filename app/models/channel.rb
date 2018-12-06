# == Schema Information
#
# Table name: channels
#
#  id                :bigint(8)        not null, primary key
#  token             :string           not null
#  user_id           :bigint(8)        not null
#  next_chapter_id   :bigint(8)
#  last_chapter_id   :bigint(8)
#  title             :string           not null
#  description       :text
#  deliver_at        :integer          default(8)
#  public            :boolean          default(FALSE), not null
#  books_count       :integer          default(0), not null
#  subscribers_count :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Channel < ApplicationRecord
  belongs_to :user
  belongs_to :next_chapter, class_name: 'Chapter', foreign_key: 'next_chapter_id', optional: true
  belongs_to :last_chapter, class_name: 'Chapter', foreign_key: 'last_chapter_id', optional: true
  has_many :channel_books, -> { order(:index) }, dependent: :destroy
  has_many :books, through: :channel_books
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true

  before_create do
    self.token = SecureRandom.hex(10)
  end


  def current_chapter
    # 当日の配信時間を過ぎてればnext_chapter、まだならlast_chapterを返す
    if Time.current > Time.current.change(hour: self.deliver_at)
      self.next_chapter
    else
      self.last_chapter
    end
  end

  def next_channel_book
    self.channel_books.where(delivered: false).first
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
    return self.update!(last_chapter_id: self.next_chapter_id, next_chapter_id: next_chapter.id) if next_chapter

    # 次のchapterがなければ、次の本を探してindex:1でセット
    if next_channel_book
      ActiveRecord::Base.transaction do
        next_chapter = Chapter.find_by(book_id: next_channel_book.book_id, index: 1)
        self.update!(last_chapter_id: self.next_chapter_id, next_chapter_id: next_chapter.id)
        next_channel_book.update!(delivered: true)
      end
    # next_channel_bookもなければ配信停止状態にする
    else
      self.update!(last_chapter_id: self.next_chapter_id, next_chapter_id: nil)
    end
  end
end
