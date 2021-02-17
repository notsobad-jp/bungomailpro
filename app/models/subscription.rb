class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  delegate :email, prefix: true, to: :user
  delegate :google_group_key, to: :channel

  @@service = GoogleDirectoryService.instance

  # GoogleGroupを使うchannelの場合は、そっちの登録状況も更新する
  after_save do
    return if google_group_key.blank?

    # 削除
    if status == 'canceled'
      @@service.delete_member(google_group_key, user_email)
    # 登録・配信停止・再開
    else
      delivery_settings = status == 'active' ? 'ALL_MAIL' : 'NONE'
      member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
      @@service.update_member(google_group_key, user_email, member)
    end
  end
end
