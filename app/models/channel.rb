class Channel < ApplicationRecord
  belongs_to :user
  has_one :search_condition, dependent: :destroy
  has_many :book_assignments, dependent: :destroy
  has_one :current_book_assignment, -> { where(status: :active) }, class_name: 'BookAssignment'
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  validates :title, presence: true
  accepts_nested_attributes_for :search_condition
  accepts_nested_attributes_for :book_assignments

  # 言語別の公式チャネルID
  DEFAULT_CHANNEL_ID = {
    ja: '821b9354-8ce4-4706-8fdc-6ac42c16e053',
    en: '4c386a3c-ed38-4e6e-8505-334a6e9f5043'
  }.freeze

  after_create do
    self.subscriptions.create(user_id: self.user_id)
  end

  def assign_book_and_set_feeds(deliver_now: false)
    # ストック済みの本があればそれを配信
    if (book_assignment = book_assignments.stocked.order(:created_at).first)
      book_assignment.active!
    elsif search_condition
      # 検索条件が保存されてる場合はそこからセレクト
      book_class = search_condition.book_type.constantize
      # TODO: あらかじめbook_idsを保存しておいてクエリ実行せずに選べるようにする
      # TODO: 該当する本がないときのフォールバック処理
      book = book_class.search(search_condition.query).order(Arel.sql("RANDOM()")).first
      book_assignment = self.book_assignments.create(book_type: book.class.name, book_id: book.id, status: :active)
    else
      # それもなければデフォルト条件でセレクト
      book = self.select_book.first
      book_assignment = self.book_assignments.create(book_type: book.class.name, book_id: book.id, status: :active)
    end
    book_assignment.set_feeds

    # TODO: UTCの配信時間以前なら予約・以降ならすぐに配信される
    UserMailer.feed_email(book_assignment.next_feed).deliver if deliver_now
  end

  def select_book(num=1)
    ids = ActiveRecord::Base.connection.select_values("select guten_book_id from guten_books_subjects where subject_id IN (select id from subjects where LOWER(id) LIKE '%fiction%')")
    GutenBook.where(id: ids, language: 'en', rights_reserved: false, words_count: 2000..15000).where("downloads > ?", 50).order(Arel.sql("RANDOM()")).take(num)
  end
end
