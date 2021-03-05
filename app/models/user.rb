class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :membership, foreign_key: :id, dependent: :destroy
  has_many :membership_logs, dependent: :destroy
  has_many :channels, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  delegate :plan, :status, to: :membership, prefix: true, allow_nil: true

  validates :email, presence: true, uniqueness: true
  validates_format_of :email, without: /.*\+.*@gmail\.com/, on: :create  # gmailエイリアスアドレスでの登録は弾く （リニューアル以前に登録されたアドレスがあるので on: :create のみ）

  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  # 新規作成時（未activation）: EmailDigest作成
  after_create do
    EmailDigest.find_or_create_by!(digest: Digest::SHA256.hexdigest(email)) # 退会済みユーザーの場合はEmailDigestが存在する
  end

  # activation実行時: Membership作成
  after_update if: Proc.new { |user| user.saved_change_to_activation_state == ['pending', 'active'] } do
    Membership.create!(id: self.id, plan: 'free', trial_end_at: email_digest.trial_ended_at)  # トライアル→退会→再登録の場合: 最初からトライアル終了状態で作成
  end


  def email_digest
    EmailDigest.find(Digest::SHA256.hexdigest(email))
  end
end
