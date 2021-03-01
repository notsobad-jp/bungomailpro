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
  after_create :create_email_digest
  after_update :create_membership, if: Proc.new { |user| user.activation_state_changed? && user.activation_state == 'active' }
  after_destroy :update_email_digest

  validates :email, presence: true, uniqueness: true


  private

  def create_membership
    Membership.create!(id: self.id, plan: 'free')
  end

  def create_email_digest
    EmailDigest.create!(digest: BCrypt::Password.create(email))
  end

  def update_email_digest
    EmailDigest.find_by(digest: BCrypt::Password.create(email)).update!(deleted_at: Time.current)
  end
end
