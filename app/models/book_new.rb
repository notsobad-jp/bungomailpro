# == Schema Information
#
# Table name: books
#
#  id             :bigint(8)        not null, primary key
#  title          :string           not null
#  author         :string           not null
#  author_id      :bigint(8)        not null
#  file_id        :bigint(8)
#  footnote       :text
#  chapters_count :integer          default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class BookNew < ApplicationRecord
  self.primary_key = 'id'
  self.table_name = 'books_new'
end
