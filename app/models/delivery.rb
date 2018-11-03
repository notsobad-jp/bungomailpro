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
    UserMailer.with(delivery: self).deliver_chapter.deliver_later

    self.update(delivered: true)
    self.user_course.set_next_delivery
  end
end
