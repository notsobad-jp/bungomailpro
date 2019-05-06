# == Schema Information
#
# Table name: notifications
#
#  id         :bigint(8)        not null, primary key
#  text       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Notification < ApplicationRecord
end
