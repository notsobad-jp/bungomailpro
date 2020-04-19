# == Schema Information
#
# Table name: users
#
#  id                           :uuid             not null, primary key
#  crypted_password             :string
#  delivery_time                :string           default("07:00")
#  email                        :string           not null
#  magic_login_email_sent_at    :datetime
#  magic_login_token            :string
#  magic_login_token_expires_at :datetime
#  remember_me_token            :string
#  remember_me_token_expires_at :datetime
#  salt                         :string
#  timezone                     :string           default("UTC")
#  words_per_day                :integer          default(400)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_users_on_email              (email) UNIQUE
#  index_users_on_magic_login_token  (magic_login_token)
#  index_users_on_remember_me_token  (remember_me_token)
#

class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :charge, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  # ユーザー作成時にmagic_login_tokenも発行しておく
  after_create do
    self.generate_magic_login_token!
  end


  def assign_book_and_set_feeds(deliver_now: false)
    # ストック済みがあればそれをセット、なければ新しく本をセレクト
    if (book_assignment = book_assignments.stocked.order(:created_at).first)
      book_assignment.active!
    else
      book = self.select_book
      book_assignment = self.book_assignments.create(guten_book_id: book.id, status: :active)
    end
    book_assignment.set_feeds

    # TODO: UTCの配信時間以前なら予約・以降ならすぐに配信される
    UserMailer.feed_email(book_assignment.next_feed).deliver if deliver_now
  end

  def current_book_assignment
    self.book_assignments.includes(:guten_book, :feeds).find_by(status: :active)
  end

  def select_book
    ids = ActiveRecord::Base.connection.select_values("select guten_book_id from guten_books_subjects where subject_id IN (select id from subjects where LOWER(id) LIKE '%fiction%')")
    GutenBook.where(id: ids, language: 'en', rights_reserved: false, words_count: 2000..15000).where("downloads > ?", 50).order(Arel.sql("RANDOM()")).first
  end

  # 配信時間とTZの時差を調整して、UTCとのoffsetを算出（単位:minutes）
  def utc_offset
    # UTC00:00から配信時間までの分数（必ずプラス）
    ## "08:10" => [8, 10] => [480, 10] => +490(minutes)
    delivery_offset = self.delivery_time.split(":").map(&:to_i).zip([60, 1]).map{|a,b| a*b }.sum

    # UTCとユーザーTimezoneの差分（プラスマイナスどちらもありえる）
    timezone_offset = ActiveSupport::TimeZone.new(self.timezone).utc_offset / 60

    # offsetの結果、前日や翌日に日がまたぐ場合もいい感じに調整する（e.g. -01:00 => 23:00, 27:00 => 03:00）
    (delivery_offset - timezone_offset) % (24 * 60)
  end
end
