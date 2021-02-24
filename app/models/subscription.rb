class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  enum status: { active: 1, paused: 2, canceled: 3 }
  delegate :email, prefix: true, to: :user

  @@service = GoogleDirectoryService.instance

  after_create  :google_insert_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }
  after_update  :google_update_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }
  after_destroy :google_delete_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }

  private

  def google_insert_member
    begin
      member = Google::Apis::AdminDirectoryV1::Member.new(email: user_email)
      @@service.insert_member(channel.google_group_key, member)
    rescue => e
      logger.error e
    end
  end

  def google_update_member
    begin
      delivery_settings = paused? ? 'NONE' : 'ALL_MAIL'
      member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
      @@service.update_member(channel.google_group_key, user_email, member)
    rescue => e
      logger.error e
    end
  end

  def google_delete_member
    begin
      @@service.delete_member(channel.google_group_key, user_email)
    rescue => e
      logger.error e
    end
  end
end
