class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :channel

  delegate :email, prefix: true, to: :user
  delegate :google_group_key, to: :channel

  @@service = GoogleDirectoryService.instance

  # GoogleGroupを使うChannelの場合は、更新後にそっちの登録状況も更新する
  after_create :insert_google_member, if: -> { google_group_key.present? } # 新規作成時はGoogleにも作成
  after_destroy :delete_google_member, if: -> { google_group_key.present? } # 削除時はGoogleからも削除
  after_update :update_google_member , if: -> { google_group_key.present? } # 更新時はGoogleでは更新・作成・削除が全部ありえる

  private

  # TODO: 全体的に例外処理を追加（失敗してもログだけ残してtransactionは完了させたい）
  def insert_google_member
    member = Google::Apis::AdminDirectoryV1::Member.new(email: user_email)
    @@service.insert_member(google_group_key, member)
  end

  def update_google_member
    return delete_google_member if status == 'canceled' # 解約時もレコード自体はcanceledで残るのでここで削除処理
    return insert_google_member if status == 'active' && status_before_last_save == 'canceled' # 解約→再登録時は既存レコードの更新になるのでここで追加処理

    delivery_settings = status == 'active' ? 'ALL_MAIL' : 'NONE'
    member = Google::Apis::AdminDirectoryV1::Member.new(delivery_settings: delivery_settings)
    @@service.update_member(google_group_key, user_email, member)
  end

  def delete_google_member
    @@service.delete_member(google_group_key, user_email)
  end
end
