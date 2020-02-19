# == Schema Information
#
# Table name: notifications
#
#  id         :uuid             not null, primary key
#  content    :text
#  send_at    :datetime
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Notification < ApplicationRecord
  def schedule_email
    UserMailer.notification_email(self).deliver
  end
end
