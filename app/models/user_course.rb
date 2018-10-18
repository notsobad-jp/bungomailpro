# == Schema Information
#
# Table name: user_courses
#
#  id             :bigint(8)        not null, primary key
#  user_id        :bigint(8)        not null
#  course_id      :bigint(8)        not null
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


  # 次の配信日時を取得
  def next_deliver_at
    # 一番最初に見つけた未来の配信時間を返す
    self.delivery_hours.each do |time|
      return time.in_time_zone if Time.zone.now < time.in_time_zone
    end
    # 未来時間がなければ翌日日付で最初の配信時間を返す
    return self.delivery_hours.first.in_time_zone.tomorrow
  end


  # 最後に配信した内容を取得
  def last_delivery
    self.deliveries.order(id: :desc).first
  end


  #TODO: 配信時間変更
  def change_delivery_hours
  end


  def set_next_delivery
    last_delivery = self.last_delivery

    if last_delivery
      next_chapter = last_delivery.chapter.next_chapter
    else
      first_book_id = self.course.first_book_id
      next_chapter = Chapter.find_by(book_id: first_book_id, index: 1)
    end

    # 次のchapterがなかったら、courseの次の本を探す
    if !next_chapter
      next_book_id = self.course.next_book_id(last_delivery.chapter.book_id)
      return self.update(status: 3) if !next_book_id  # 次の本がなかったら配信完了
      next_chapter = Chapter.find_by(book_id: next_book_id, index: 1)
    end

    self.deliveries.create(
      chapter_id: next_chapter.id,
      deliver_at: self.next_deliver_at
    )
  end


  def skip_current_book
    next_book_id = self.course.next_book_id(self.last_delivery.chapter.book_id)
    return self.update(status: 3) if !next_book_id  # 次の本がなかったら配信完了
    next_chapter = Chapter.find_by(book_id: next_book_id, index: 1)

    self.deliveries.find_by(delivered: false).destroy
    self.deliveries.create(
      chapter_id: next_chapter.id,
      deliver_at: self.next_deliver_at
    )
  end


  # 一時停止
  def pause
    self.deliveries.find_by(delivered: false).update(deliver_at: nil)
  end


  # 配信再開
  def restart
    self.deliveries.find_by(delivered: false).update(deliver_at: self.next_deliver_at)
  end
end
