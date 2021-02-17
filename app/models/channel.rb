class Channel < ApplicationRecord
  belongs_to :user
  has_one :channel_profile, foreign_key: :id, dependent: :destroy
  has_many :book_assignments, dependent: :destroy

  delegate :title, :description, :google_group_key, to: :channel_profile, allow_nil: true
end
