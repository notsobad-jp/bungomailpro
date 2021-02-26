class Channel < ApplicationRecord
  belongs_to :user
  has_one :channel_profile, foreign_key: :id, dependent: :destroy
  has_many :book_assignments, dependent: :destroy
  has_many :delayed_jobs, through: :book_assignments
  has_many :subscriptions
  has_many :active_subscriptions, -> { where status: 'active' }, class_name: 'Subscription'
  has_many :active_subscribers, through: :active_subscriptions, source: :user

  delegate :title, :description, :google_group_key, to: :channel_profile, allow_nil: true

  # delivery_timeが更新されたときは予約中のjobの配信時間も更新する
  after_update  :update_jobs_delivery_time, if: :saved_change_to_delivery_time?

  OFFICIAL_CHANNEL_ID = '1418479c-d5a7-4d29-a174-c5133ca484b6'
  JUVENILE_CHANNEL_ID = '470a73fb-d1ae-4ffb-9c6b-5b9dc292f4ef'

  
  def update_jobs_delivery_time
  end
end
