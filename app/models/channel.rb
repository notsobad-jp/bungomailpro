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
  has_many :comments, dependent: :destroy
  accepts_nested_attributes_for :channel_books, allow_destroy: true

  validates :title, presence: true

  before_create do
    self.token = SecureRandom.hex(10)
  end

  after_create do
    self.subscriptions.create!(user_id: self.user_id)
  end


  def add_comment
    # 同じ本で次のchapterがあれば継続配信なのでcomment不要
    return if self.next_chapter.next_chapter

    comment = self.comments.new(date: Time.current.tomorrow)
    if next_chapter_book
      comment.text = 'この作品の配信は本日で終了です。翌日からは次の作品の配信が始まります。'
    else
      comment.text = 'この作品の配信は本日で終了です。現在次の作品が登録されていないため、チャネルは配信停止状態になります。再開する際は作品を追加して再度「配信開始」してください。'
    end
    comment.save!
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
