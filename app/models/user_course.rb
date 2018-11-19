# == Schema Information
#
# Table name: user_courses
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)
#  course_id      :bigint(8)
#  status         :integer          default(1), not null
#  delivery_hours :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class UserCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :deliveries, dependent: :destroy
  serialize :delivery_hours

  validates :status, inclusion: { in: [1,2,3] }


  #TODO: 配信時間変更
  def change_delivery_hours
  end


  def set_deliveries
    return self.update(status: 3) if !next_book  # 次の本がなかったら配信完了

    next_book.splited_text.each.with_index(1) do |text, index|
      self.deliveries.build(
        book_id: next_book.id,
        index: index,
        text: text,
        deliver_at: next_deliver_at + (index-1).day
      )
    end
    self.increment(:next_book_index)
    self.save
  end
  handle_asynchronously :set_deliveries


  def skip_current_book
    self.deliveries.where(delivered: false).delete_all
    set_deliveries
  end


  # 一時停止
  def pause
    self.deliveries.where(delivered: false).delete_all
  end


  # 配信再開
  def restart
    current_book.splited_text.each.with_index(next_delivery_index) do |text, index|
      self.deliveries.build(
        book_id: current_book.id,
        index: index,
        text: text,
        deliver_at: next_deliver_at + (index-1).day
      )
    end
    self.save
  end
  handle_asynchronously :restart

  def active?
    self.status == 1
  end

  def paused?
    self.status == 2
  end

  def finished?
    self.status == 3
  end

  def next_delivery
    self.deliveries.includes(:book).where(delivered: false).order(:deliver_at).first
  end

  def delivery_count(book_id)
    self.deliveries.where(book_id: book_id).count
  end

  def delivered_course_books
    self.course.course_books.includes(:book).where("index < ?", self.next_book_index).order(:index)
  end

  # 次の配信日時を取得
  def next_deliver_at
    # 一番最初に見つけた未来の配信時間を返す
    self.delivery_hours.each do |time|
      return time.in_time_zone if Time.zone.now < time.in_time_zone
    end
    # 未来時間がなければ翌日日付で最初の配信時間を返す
    return self.delivery_hours.first.in_time_zone.tomorrow
  end


  private
    def current_book
      current_book_index = [self.next_book_index - 1, 1].max
      self.course.course_books.includes(:book).find_by(index: current_book_index).try(:book)
    end

    def next_book
      self.course.course_books.includes(:book).find_by(index: self.next_book_index).try(:book)
    end

    def last_delivery
      self.deliveries.order(deliver_at: :desc).first
    end

    def next_delivery_index
      #[TODO]次の本の初回を配信せずに中断・再開した場合は？
      last_delivery ? last_delivery.index + 1 : 1
    end
end
