# == Schema Information
#
# Table name: users
#
#  id                           :uuid             not null, primary key
#  crypted_password             :string
#  delivery_time                :string           default("07:00")
#  email                        :string           not null
#  magic_login_email_sent_at    :datetime
#  magic_login_token            :string
#  magic_login_token_expires_at :datetime
#  remember_me_token            :string
#  remember_me_token_expires_at :datetime
#  salt                         :string
#  timezone                     :string           default("UTC")
#  words_per_day                :integer          default(400)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_users_on_email              (email) UNIQUE
#  index_users_on_magic_login_token  (magic_login_token)
#  index_users_on_remember_me_token  (remember_me_token)
#

class User < ApplicationRecord
  authenticates_with_sorcery!

  has_one :charge, dependent: :destroy
  has_many :skip_histories, dependent: :destroy

  # トライアル終了日が現時刻より先 && 1ヶ月後よりは手前 = トライアル期間1ヶ月に現時刻が含まれる
  scope :trialing, -> (date = Time.current) { where(trial_end_at: date..date.next_month) }
  # 決済情報が登録されてる && 決済情報が有効（trialing, active, past_due）
  ## past_dueは何回か失敗後にcanceledになって、そのタイミングでリストからも除外するので一旦active扱いでOK
  scope :charging, -> { left_joins(:charge).where(charges: {status: %w(trialing active past_due)}) }
  # 決済情報が登録されていない OR 決済情報が無効（canceled, unpaid）
  scope :not_charging, -> { left_joins(:charge).where(charges: {id: nil}).or(left_joins(:charge).where(charges: {status: %w(canceled unpaid)})) }
  # 配信停止中のvalidなユーザー（一時停止中の課金ユーザー || お試し期間中のユーザー）
  scope :valid_and_paused, -> (date = Time.current) { charging.or(left_joins(:charge).trialing(date)).where(list_subscribed: false) }
  # 配信中のinvalidなユーザー（お試し期間が終了した非課金ユーザー）（
  scope :invalid_and_subscribing, -> (date = Time.current) { not_charging.where("trial_end_at < ?", date).where(list_subscribed: true) }

  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }


  def trial_start_at
    trial_end_at.beginning_of_month
  end

  def before_trial?
    trial_start_at > Time.current
  end

  def trialing?
    trial_start_at < Time.current && Time.current < trial_end_at
  end

  # トライアル開始前の状態から、すぐにトライアルを開始する
  ## トライアル終了日時も翌月末→今月末に繰り上げ
  def start_trial_now
    add_to_list
    update(
      list_subscribed: true,
      trial_end_at: Time.current.end_of_month
    )
    # TODO: chargeも作成済みだったらそっちのtrialも繰り上げる
  end

  # 配信リストから除外（「月末まで停止」に使用）して履歴に記録
  def pause_subscription
    remove_from_list
    update(list_subscribed: false)
    skip_histories.create
  end


  #######################################
  # Sendgrid用メソッド
  #######################################
  def create_recipient
    Sendgrid.call(path: "contactdb/recipients", params: [{ email: email }])
  end

  def add_to_list
    Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: [sendgrid_id])
  end

  def remove_from_list
    Sendgrid.call(path: "contactdb/lists/#{CampaignGroup::LIST_ID}/recipients", params: [sendgrid_id], method: :delete)
  end
end
