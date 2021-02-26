class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  delegate :email, prefix: true, to: :user

  @@service = GoogleDirectoryService.instance

  # FIXME: 2021年2月末のデータ移行が終わるまでは、事故防止のため一時停止
  # after_create  :google_insert_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }
  # after_update  :google_update_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }
  # after_destroy :google_delete_member, if: Proc.new { |sub| sub.channel.google_group_key.present? }

  private

  def google_insert_member
    member = Google::Apis::AdminDirectoryV1::Member.new(email: user_email)
    @@service.insert_member(channel.google_group_key, member)
  end

  def google_update_member
    delivery_settings = paused? ? 'NONE' : 'ALL_MAIL'
    member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
    @@service.update_member(channel.google_group_key, user_email, member)
  end

  def google_delete_member
    @@service.delete_member(channel.google_group_key, user_email)
  end
end
