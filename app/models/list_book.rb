# == Schema Information
#
# Table name: list_books
#
#  id         :bigint(8)        not null, primary key
#  list_id    :bigint(8)
#  book_id    :bigint(8)
#  index      :integer          not null
#  comment    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ListBook < ApplicationRecord
  belongs_to :list, required: false
  belongs_to :book

  validates :index, presence: true
end
