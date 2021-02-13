class Channel < ApplicationRecord
  has_many :book_assignments, dependent: :destroy
end
