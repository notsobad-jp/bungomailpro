class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  delegate :email, prefix: true, to: :user
  delegate :google_group_key, to: :channel

  @@service = GoogleDirectoryService.instance

  # GoogleGroupにメンバー追加
  after_create do
    return if google_group_key.blank?
    member = Google::Apis::AdminDirectoryV1::Member.new(email: user_email)
    @@service.insert_member(google_group_key, member)
  end

  # GoogleGroupで配信設定を変更（一時停止・再開）
  after_update do
    return if google_group_key.blank?
    delivery_settings = self.paused ? 'NONE' : 'ALL_MAIL'
    member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
    @@service.patch_member(google_group_key, user_email, member)
  end

  # GoogleGroupからメンバー削除
  after_destroy do
    return if google_group_key.blank?
    @@service.delete_member(google_group_key, user_email)
  end
end
