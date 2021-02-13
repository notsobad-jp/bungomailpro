class BookAssignment < ApplicationRecord
  belongs_to :channel
  belongs_to :book, polymorphic: true
  has_many :chapters, dependent: :destroy
  has_many :delayed_jobs, through: :chapters, dependent: :destroy
end
