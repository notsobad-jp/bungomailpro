# == Schema Information
#
# Table name: subscriptions
#
#  id                 :uuid             not null, primary key
#  delivery_hour      :integer          default(8), not null
#  footer             :text
#  next_chapter_index :integer
#  next_delivery_date :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  channel_id         :uuid             not null
#  current_book_id    :bigint(8)
#  user_id            :uuid             not null
#
# Indexes
#
#  index_subscriptions_on_channel_id              (channel_id)
#  index_subscriptions_on_current_book_id         (current_book_id)
#  index_subscriptions_on_user_id                 (user_id)
#  index_subscriptions_on_user_id_and_channel_id  (user_id,channel_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (channel_id => channels.id)
#  fk_rails_...  (current_book_id => books.id)
#  fk_rails_...  (user_id => users.id)
#

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel, counter_cache: :subscribers_count
  belongs_to :current_book, class_name: 'Book', foreign_key: 'current_book_id', optional: true
  belongs_to :next_chapter, class_name: 'Chapter', foreign_key: %i[current_book_id next_chapter_index], optional: true
  has_many :feeds, -> { order(delivered_at: :desc) }, dependent: :destroy, inverse_of: :subscription
  has_many :comments, dependent: :destroy, inverse_of: :subscription

  validates :delivery_hour, presence: true
  validates_associated :user

  def create_feed
    feeds.create!(
      book_id: current_book_id,
      index: next_chapter_index,
      delivered_at: next_deliver_at
    )
  end

  def current_channel_book
    ChannelBook.find_by(channel_id: channel_id, book_id: current_book_id)
  end

  def current_chapter
    return unless next_chapter_index # 配信完了状態ではnilを返す
    return next_chapter if not_started? # 配信開始前は常にnext_chapterを返す

    # 配信時間を過ぎてればnext_chapter、それ以前ならprev_chapterを返す
    Time.current > Time.current.change(hour: delivery_hour) ? next_chapter : prev_chapter
  end

  def current_comment
    return unless next_chapter_index # 配信完了状態ではnilを返す

    comments.find_by(book_id: current_book_id, index: next_chapter_index)
  end

  # メール送信して、RSSフィードに追加して、配信情報を更新する
  ## TODO: メール配信でコケたらその後の処理も止まるけど、途中でコケるとメールだけ送られてしまう問題
  def deliver_and_update
    return unless current_book_id # もし配信終了してるときはスキップ（2月で2回配信するときに配信終了状態で来る可能性がある）
    return if next_delivery_date != Time.zone.today # 配信日が今日じゃなければスキップ（TODO: 配信後日付を更新する前に2回処理予約されると、ここを通過して重複処理されてしまう可能性がある）

    # 有料ユーザーのみメール配信
    UserMailer.with(subscription: self).chapter_email.deliver_now # deliver_nowだけどSendGrid側で予約配信するのでまだ送られない

    # ブンゴウメール公式チャネルのみ、グループアドレスにtextメールを追加配信して LINEにも配信
    if self.channel_id == Channel::BUNGOMAIL_ID
      UserMailer.with(subscription: self).bungo_email.deliver_now
      Line.broadcast(self)
    end

    self.footer = ActionController::Base.helpers.strip_tags(footer) # なぜかURLがaタグ化して保存されてしまうのを回避

    # RSSフィードと次の配信情報の更新（無料ユーザーも）
    create_feed
    set_next_chapter
  end

  # 実際にメール配信する宛先のリスト（=有料プラン契約済みのメールアドレス一覧）
  def deliverable_emails
    subscribers = channel.streaming? ? channel.subscribers : Array(user) # streamingじゃないときはownerだけだけど、returnを揃えられるようArrayに統一
    subscribers.select(&:pro?).reject{|s| s.email == 'bungomail-text@notsobad.jp' }.pluck(:email)
  end

  # current_bookがなければ配信停止状態と判断
  ## ただしstreamingのときは配信情報がもともと空なので対象から除外する
  def finished?
    !current_book_id && !channel.streaming?
  end

  def finished_books
    channel.channel_books.where('index < ?', current_book_index).map(&:book)
  end

  # next_chapterを配信したあと、次に配信するchapter
  def next_next_chapter
    return unless next_chapter # そもそもnext_chapterがなければnil

    # 同じ本で次のchapterがあればそれを返す。なければ、次の本の最初のchapterを返す
    if next_chapter.next
      next_chapter.next
    elsif (next_channel_book = current_channel_book.next)
      next_channel_book.book.chapters.first
    end
  end

  def next_deliver_at
    return unless next_delivery_date

    Time.zone.parse(next_delivery_date.to_s).change(hour: delivery_hour)
  end

  # 最初の本の最初のchapter配信前
  def not_started?
    next_chapter_index == 1 && current_channel_book.index == 1
  end

  def prev_chapter
    return unless next_chapter_index

    # 同じ本で前のchapterが存在すればそれを返す
    return next_chapter.prev if next_chapter_index > 1

    # なければ前の本を見るけど、前の本もない場合（＝最初の本の最初の配信前）はnil
    return if current_channel_book.index == 1

    # 前の本があれば、その最後のchapterを返す
    prev_channel_book = current_channel_book.prev
    prev_channel_book.book.chapters.last
  end

  def scheduled_books
    channel.channel_books.where('index > ?', current_book_index).map(&:book)
  end

  def set_next_chapter
    # 次回配信は基本翌日。翌日が31日だった場合のみ飛ばしてその次の日(1日)をセット
    tomorrow = Time.zone.tomorrow
    next_delivery_date = tomorrow.day == 31 ? tomorrow.tomorrow : tomorrow

    # next_next_chapterが存在すればそれをセット
    if next_next_chapter
      update!(
        current_book_id: next_next_chapter.book_id,
        next_chapter_index: next_next_chapter.index,
        next_delivery_date: next_delivery_date
      )
    # next_next_chapterがなければ配信停止状態にする
    else
      update!(
        current_book_id: nil,
        next_chapter_index: nil,
        next_delivery_date: nil
      )
    end
    logger.info "[CHAPTER SET] sub:#{id}, #{next_chapter.try(:book_id)}-#{next_chapter.try(:index)}"
  end

  private

  # 配信終了（current_channel_bookがnil）の場合は最大値を返す
  def current_book_index
    current_channel_book.try(:index) || Float::MAX
  end
end
