# == Schema Information
#
# Table name: deliveries
#
#  id             :bigint(8)        not null, primary key
#  user_course_id :bigint(8)
#  book_id        :bigint(8)
#  index          :integer          not null
#  text           :text
#  deliver_at     :datetime
#  delivered      :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Delivery < ApplicationRecord
  belongs_to :book
  belongs_to :user_course
  has_one :user, through: :user_course


  def deliver
    #TMP: UserMailer.with(delivery: self).deliver_chapter.deliver_later
    self.update(delivered: true)

    # 最後の配信なら次の作品をセット
    self.user_course.set_deliveries if !Delivery.find_by(user_course_id: self.user_course.id, delivered: false)
    self.user_course.increment!(:next_book_id)
  end
end
