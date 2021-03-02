class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :membership, foreign_key: :id, dependent: :destroy
  has_many :membership_logs, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  delegate :plan, :status, to: :membership, prefix: true, allow_nil: true

  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  # リニューアル以前の退会ユーザーは再登録可能にする
  before_create do
    email_digest = EmailDigest.find_by(digest: Digest::SHA256.hexdigest(email))
    if email_digest && email_digest.deleted_at < Time.zone.parse("2021-12-31")  # FIXME: リニューアル以前かどうかで判定
      email_digest.destroy!
    end
  end

  after_create :create_email_digest
  after_update :create_membership, if: Proc.new { |user| user.saved_change_to_activation_state == ['pending', 'active'] }
  after_destroy :update_email_digest

  validates :email, presence: true, uniqueness: true


  private

  def create_membership
    Membership.create!(id: self.id, plan: 'free')
  end

  def create_email_digest
    EmailDigest.create!(digest: Digest::SHA256.hexdigest(email))
  end

  def update_email_digest
    EmailDigest.find_by(digest: Digest::SHA256.hexdigest(email)).update!(deleted_at: Time.current)
  end
end
