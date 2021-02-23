class SubscriptionLog < ActivityLog
  belongs_to :user
  belongs_to :channel
  belongs_to :membership_log, required: false

  enum status: { active: 1, paused: 2, canceled: 3 }
  delegate :email, prefix: true, to: :user

  @@service = GoogleDirectoryService.instance


  def self.apply_all
    logs = self.applicable
    return if logs.blank?
    Subscription.upsert_all(logs.map(&:upsert_attributes), unique_by: [:user_id, :channel_id])
    logs.update_all(finished: true)

    # GoogleGroupを使うChannelの場合はそっちの購読状況も更新
    logs.each do |log|
      log.update_google_subscription if log.google_action.present?
      sleep 1
    end
  end

  def upsert_attributes
    attributes = self.slice(:user_id, :channel_id, :status)
    attributes[:updated_at] = self.apply_at
    attributes
  end

  def update_google_subscription
    case google_action
    when 'insert'
      member = Google::Apis::AdminDirectoryV1::Member.new(email: user_email)
      @@service.insert_member(channel.google_group_key, member)
    when 'update'
      delivery_settings = status == 'active' ? 'ALL_MAIL' : 'NONE'
      member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
      @@service.update_member(channel.google_group_key, user_email, member)
    when 'delete'
      @@service.delete_member(channel.google_group_key, user_email)
    end
  rescue => e
    logger.error e
  end
end
