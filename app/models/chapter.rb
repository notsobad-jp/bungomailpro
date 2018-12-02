# == Schema Information
#
# Table name: chapters
#
#  id         :bigint(8)        not null, primary key
#  book_id    :bigint(8)        not null
#  index      :integer          not null
#  text       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Chapter < ApplicationRecord
  belongs_to :book, counter_cache: true
end
