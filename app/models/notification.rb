# == Schema Information
#
# Table name: notifications
#
#  id         :bigint(8)        not null, primary key
#  date       :date             not null
#  text       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_notifications_on_date  (date) UNIQUE
#

class Notification < ApplicationRecord
end
