class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  delegate :email, prefix: true, to: :user
  @@service = GoogleDirectoryService.instance

  def self.restart_all
    self.includes(channel: :channel_profile).where(paused: true).each do |sub|
      sub.update!(paused: false)

      # 2021.3.31: まだcallback設定してないのでGroupの配信設定を手動変更
      # sleep 0.5 if sub.channel.google_group_key.present?
      begin
        member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: 'ALL_MAIL')
        @@service.update_member('bungomail-text@notsobad.jp', sub.user_email, member)
        sleep 1
      rescue => e
        logger.error "[Error] google update failed: #{sub.id} #{e}"
        e
      end
    end
  end
end
