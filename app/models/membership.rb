class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  after_create do
    # Freeプランの無料チャネルをすぐに購読開始
    user.subscriptions.create!(channel_id: Channel::JUVENILE_CHANNEL_ID)
  end
  after_update :start_trialing, if: :trialing_started?
  after_update :cancel_basic_plan, if: :basic_plan_canceled?
  after_update :cancel_free_plan, if: :free_plan_canceled?


  def schedule_trial
    raise 'already in basic' if plan == 'basic'
    self.membership_logs.create!(plan: 'basic', trialing: true, apply_at: Time.current.next_month.beginning_of_month)  # 翌月初からトライアル開始
    self.membership_logs.create!(plan: 'free', apply_at: Time.current.since(2.month).beginning_of_month) # 変更がなければ翌々月初からfreeプランに戻る
    self.update!(trial_end_at: Time.current.next_month.end_of_month)
  end

  # 決済情報登録して、翌月末かトライアル終了後から課金開始
  ## トライアル開始前 -> 翌々月初、 トライアル中 -> 翌月初、 トライアル終了後 -> 翌月初
  def schedule_billing
    raise 'already billing' if plan == 'basic' && !trialing?   # ありえるのは free-active OR basic-trialingからの登録
    self.membership_logs.scheduled.update_all(canceled: true)
    self.membership_logs.create!(plan: 'basic', apply_at: billing_start_at)
  end

  # 月末で解約してfreeプランに戻る
  def cancel_billing
    raise 'not billing' unless plan_status == 'basic-active'
    # TODO: 解約予約をどうやって表現するか
    # self.membership_logs.create!(plan: 'free', status: :active, apply_at: Time.current.next_month.beginning_of_month)
  end


  private

  def billing_start_at
    [trial_end_at.since(1.second), Time.current.next_month.beginning_of_month].max
  end

  ###########################################################
  # callbackの条件判定メソッド
  ###########################################################
  def plan_or_trialing_changed?
    (saved_changes.keys & ['plan', 'trialing']).present?
  end

  def trialing_started?
    plan_or_trialing_changed? && plan == 'basic' && trialing?
  end

  def basic_plan_canceled?
    # TODO: 修正
    saved_change_to_plan == ['basic', 'free']
  end

  def free_plan_canceled?
    # TODO: 修正
    # plan_or_trialing_changed? && plan == 'free' && canceled?
  end

  ###########################################################
  # callbackの処理実行メソッド
  ###########################################################
  # trial開始: 公式チャネル購読
  def start_trialing
    user.subscriptions.create!(channel_id: Channel::OFFICIAL_CHANNEL_ID)
  end

  # basicプラン解約: 無料チャネル以外解約・自作チャネルの削除・配信停止
  def cancel_basic_plan
    user.channels.destroy_all  # 自作チャネルと配信予約を削除
    user.subscriptions.where.not(channel_id: Channel::JUVENILE_CHANNEL_ID).destroy_all # 児童チャネル以外配信停止
  end

  # 退会: すべてのチャネル解約・自作チャネルの削除・配信停止
  def cancel_free_plan
    user.destroy!
  end
end
