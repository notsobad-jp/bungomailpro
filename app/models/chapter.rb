# == Schema Information
#
# Table name: chapters
#
#  book_id    :bigint(8)        not null, primary key
#  index      :integer          not null, primary key
#  text       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Chapter < ApplicationRecord
  self.primary_keys = :book_id, :index
  belongs_to :book

  def next
    Chapter.find_by(book_id: self.book_id, index: self.index + 1)
  end

  def prev
    Chapter.find_by(book_id: self.book_id, index: self.index - 1) if self.index > 1
  end
end
