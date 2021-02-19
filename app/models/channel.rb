class Channel < ApplicationRecord
  belongs_to :user
  has_one :channel_profile, foreign_key: :id, dependent: :destroy
  has_many :book_assignments, dependent: :destroy
  has_many :subscriptions
  has_many :active_subscriptions, -> { where status: 'active' }, class_name: 'Subscription'
  has_many :active_subscribers, through: :active_subscriptions, source: :user

  delegate :title, :description, :google_group_key, to: :channel_profile, allow_nil: true


  # チャネルの即時購読
  def add_subscriber(user)
    # subscription作成・更新
    sub = Subscription.find_or_initialize_by(user_id: user.id, channel_id: self.id)
    sub.update!(status: "active")

    # 履歴管理のためにsubscription_logも作成
    google_action = 'insert' if self.google_group_key.present?
    user.subscription_logs.create!(channel_id: self.id, status: 'active', finished: true, google_action: google_action)
  end

  # チャネルの即時解約
  def delete_subscriber(user)
    # subscriptionの更新
    sub = Subscription.find_by(user_id: user.id, channel_id: self.id)
    sub.update!(status: "canceled")

    # 履歴管理のためにsubscription_logも作成
    google_action = 'delete' if self.google_group_key.present?
    user.subscription_logs.create!(channel_id: self.id, status: 'canceled', finished: true, google_action: google_action)
  end
end
