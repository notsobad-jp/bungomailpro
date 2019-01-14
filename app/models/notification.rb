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

class Notification < ApplicationRecord
end
