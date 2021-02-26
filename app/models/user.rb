class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :membership, foreign_key: :id, dependent: :destroy
  has_many :membership_logs, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscription_logs, dependent: :destroy

  delegate :plan, :status, to: :membership, prefix: true, allow_nil: true

  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  after_create :create_membership

  validates :email, presence: true, uniqueness: true

  # 退会時の処理
  def cancel_free_plan
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      membership_logs.scheduled.update_all(canceled: true)  # これ以降のステータス変更をすべてキャンセル（念のため）
      subscriptions.destroy_all # すべてのsubscriptionを解約
      channels.destroy_all  # 自作チャネルと配信予約を削除
      self.update!(activation_state: nil) # ログインできなくする
    end
  end

  # basicプラン解約時の処理
  ## 児童チャネル以外のsubscriptionを解約、自作チャネルと配信予約を削除
  def cancel_basic_plan
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      subscriptions.where.not(channel_id: Channel::JUVENILE_CHANNEL_ID).destroy_all # 児童チャネル以外配信停止
      channels.destroy_all  # 自作チャネルと配信予約を削除
    end
  end

  private

  def create_membership
    Membership.create!(id: self.id, plan: 'free', status: :active)
  end
end
