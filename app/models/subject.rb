# == Schema Information
#
# Table name: subjects
#
#  id          :string           not null, primary key
#  books_count :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Subject < ApplicationRecord
  has_and_belongs_to_many :guten_books
end
