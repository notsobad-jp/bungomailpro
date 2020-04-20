class Channel < ApplicationRecord
  belongs_to :user
  has_many :book_assignments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user

  after_create do
    self.subscriptions.create(user_id: self.user_id)
  end

  def assign_book_and_set_feeds(deliver_now: false)
    # ストック済みがあればそれをセット、なければ新しく本をセレクト
    if (book_assignment = book_assignments.stocked.order(:created_at).first)
      book_assignment.active!
    else
      book = self.select_book
      book_assignment = self.book_assignments.create(book_type: book.class.name, book_id: book.id, status: :active)
    end
    book_assignment.set_feeds

    # TODO: UTCの配信時間以前なら予約・以降ならすぐに配信される
    UserMailer.feed_email(book_assignment.next_feed).deliver if deliver_now
  end

  def current_book_assignment
    self.book_assignments.includes(:book, :feeds).find_by(status: :active)
  end

  def select_book
    ids = ActiveRecord::Base.connection.select_values("select guten_book_id from guten_books_subjects where subject_id IN (select id from subjects where LOWER(id) LIKE '%fiction%')")
    GutenBook.where(id: ids, language: 'en', rights_reserved: false, words_count: 2000..15000).where("downloads > ?", 50).order(Arel.sql("RANDOM()")).first
  end
end
