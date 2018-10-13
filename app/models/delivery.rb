# == Schema Information
#
# Table name: deliveries
#
#  id             :bigint(8)        not null, primary key
#  user_course_id :bigint(8)
#  chapter_id     :bigint(8)
#  deliver_at     :datetime
#  delivered      :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Delivery < ApplicationRecord
  belongs_to :chapter
  belongs_to :user_course
  has_one :user, through: :user_course
end
