class SubscriptionLog < ApplicationRecord
  belongs_to :user
  belongs_to :channel
  belongs_to :membership_log, required: false

  delegate :email, prefix: true, to: :user
  delegate :google_group_key, to: :channel

  scope :applicable, -> { where("apply_at < ?", Time.current).where(finished: false, canceled: false) }
  scope :scheduled, -> { where("apply_at > ?", Time.current).where(finished: false, canceled: false) }

  @@service = GoogleDirectoryService.instance


  def self.apply_all
    logs = self.applicable
    return if logs.blank?
    Subscription.upsert_all(logs.map(&:upsert_attributes), unique_by: [:user_id, :channel_id])
    logs.update_all(finished: true)

    # GoogleGroupを使うChannelの場合はそっちの購読状況も更新
    logs.each do |log|
      log.update_google_subscription if log.google_action.present?
    end
  end

  def upsert_attributes
    attributes = self.slice(:user_id, :channel_id, :status)
    attributes[:updated_at] = self.apply_at
    attributes
  end

  def update_google_subscription
    case action
    when 'insert'
      member = Google::Apis::AdminDirectoryV1::Member.new(email: user_email)
      @@service.insert_member(google_group_key, member)
    when 'update'
      delivery_settings = status == 'active' ? 'ALL_MAIL' : 'NONE'
      member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
      @@service.update_member(google_group_key, user_email, member)
    when 'delete'
      @@service.delete_member(google_group_key, user_email)
    end
  rescue => e
    logger.error e
  end
end
