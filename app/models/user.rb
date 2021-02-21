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

  after_create do
    # 正式リリース前に登録したら2021年6月末までトライアル。それ以降は翌月末までトライアル。
    trial_end_at = [Time.zone.parse("2021/06/01").end_of_month, end_of_next_month].max
    Membership.create!(id: self.id, plan: 'free', status: 'active', trial_end_at: trial_end_at)
  end

  validates :email, presence: true, uniqueness: true
end
