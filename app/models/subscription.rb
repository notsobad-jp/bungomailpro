class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  delegate :email, prefix: true, to: :user

  @@service = GoogleDirectoryService.instance

  # FIXME: データ移行方針の整理が終わるまでは事故防止のため一時停止
  # after_create  :google_insert_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }
  # after_update  :google_update_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }
  # after_destroy :google_delete_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }

  def self.restart_all
    self.includes(channel: :channel_profile).where(paused: true).each do |sub|
      sub.update!(paused: false)
      sleep 0.5 if sub.channel.google_group_key.present?
    end
  end

  private

  def google_insert_member
    begin
      member = Google::Apis::AdminDirectoryV1::Member.new(email: user_email)
      @@service.insert_member(channel.google_group_key, member)
    rescue => e
      logger.error "[Error] google insert failed: #{id} #{e}"
      e
    end
  end

  def google_update_member
    begin
      delivery_settings = paused? ? 'NONE' : 'ALL_MAIL'
      member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
      @@service.update_member(channel.google_group_key, user_email, member)
    rescue => e
      logger.error "[Error] google update failed: #{id} #{e}"
      e
    end
  end

  def google_delete_member
    begin
      @@service.delete_member(channel.google_group_key, user_email)
    rescue => e
      logger.error "[Error] google delete failed: #{id} #{e}"
      e
    end
  end
end
