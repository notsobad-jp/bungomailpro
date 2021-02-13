class Chapter < ApplicationRecord
  belongs_to :channel, through: :book_assignment
  belongs_to :book_assignment
  belongs_to :delayed_job, required: false
end
