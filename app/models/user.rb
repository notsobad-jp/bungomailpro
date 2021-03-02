class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :membership, foreign_key: :id, dependent: :destroy
  has_many :membership_logs, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  delegate :plan, :status, to: :membership, prefix: true, allow_nil: true

  validates :email, presence: true, uniqueness: true

  ##########################################
  # Callbacks
  ##########################################
  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  # リニューアル以前の退会ユーザーは再登録可能にする
  before_create do
    email_digest = EmailDigest.find_by(digest: Digest::SHA256.hexdigest(email))
    if email_digest && email_digest.updated_at < Time.zone.parse("2021-12-31")  # FIXME: リニューアル以前かどうかで判定
      email_digest.destroy!
    end
  end

  # 新規作成時（未activation）: EmailDigest作成
  after_create do
    EmailDigest.create!(digest: Digest::SHA256.hexdigest(email))
  end

  # activation実行時:
  after_update if: Proc.new { |user| user.saved_change_to_activation_state == ['pending', 'active'] } do
    Membership.create!(id: self.id, plan: 'free')
  end

  # 退会時: EmailDigestのupdated_at更新
  after_destroy do
    EmailDigest.find_by(digest: Digest::SHA256.hexdigest(email))&.touch
  end
end
