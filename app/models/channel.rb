class Channel < ApplicationRecord
  belongs_to :user
  has_many :book_assignments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
end
