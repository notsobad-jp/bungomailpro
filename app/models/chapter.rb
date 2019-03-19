# == Schema Information
#
# Table name: chapters
#
#  index      :integer          not null, primary key
#  text       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint(8)        not null, primary key
#
# Indexes
#
#  index_chapters_on_book_id            (book_id)
#  index_chapters_on_book_id_and_index  (book_id,index) UNIQUE
#  index_chapters_on_index              (index)
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#

class Chapter < ApplicationRecord
  self.primary_keys = :book_id, :index
  belongs_to :book

  def next
    Chapter.find_by(book_id: book_id, index: index + 1)
  end

  def prev
    Chapter.find_by(book_id: book_id, index: index - 1) if index > 1
  end
end
