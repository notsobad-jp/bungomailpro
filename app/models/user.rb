class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :membership, foreign_key: :id, dependent: :destroy
  has_many :membership_logs, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscription_logs, dependent: :destroy

  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  def schedule_trial
    ch_basic = Channel.find_by(code: 'bungomail-official')
    ch_free = Channel.find_by(code: 'dogramagra') # FIXME: 無料プラン用チャネル作ってそっちに差し替える
    start_at = Time.current.next_month.beginning_of_month
    end_at = start_at.end_of_month

    ActiveRecord::Base.transaction do
      # トライアル開始時
      m_log_start = self.membership_logs.create!(plan: 'basic', status: "trialing", apply_at: start_at)
      self.subscription_logs.create!(channel_id: ch_basic.id, status: 'active', apply_at: start_at, membership_log_id: m_log_start.id)

      # トライアル終了時
      m_log_cancel = self.membership_logs.create!(action: 'cancel', plan: 'basic', status: "canceled", apply_at: end_at)
      self.subscription_logs.create!(channel_id: ch_basic.id, status: 'canceled', apply_at: end_at, membership_log_id: m_log_cancel.id)
      self.subscription_logs.create!(channel_id: ch_free.id, status: 'active', apply_at: start_at.next_month, membership_log_id: m_log_cancel.id, google_action: 'insert')  # 無料版はGoogleチャネルなのでgoogle_actionも追加
    end
  end
end
