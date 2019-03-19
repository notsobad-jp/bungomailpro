# == Schema Information
#
# Table name: categories
#
#  id         :string           not null, primary key
#  name       :string           not null
#  range_from :integer
#  range_to   :integer
#
# Indexes
#
#  index_categories_on_range_from  (range_from)
#

class Category < ApplicationRecord
  self.primary_key = :id
end
