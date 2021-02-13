class Channel < ApplicationRecord
  belongs_to :user
  has_many :book_assignments, dependent: :destroy
end
