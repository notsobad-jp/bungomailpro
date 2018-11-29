# == Schema Information
#
# Table name: books
#
#  id        :bigint(8)        not null, primary key
#  title     :string           not null
#  author    :string           not null
#  author_id :bigint(8)        not null
#  footnote  :text
#

class Chapter < ApplicationRecord
  belongs_to :book
end
