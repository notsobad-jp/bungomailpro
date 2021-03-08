class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  MAXIMUM_SUBSCRIPTIONS_COUNT = { free: 1, basic: 5 }.freeze

  # freeプラン開始（activate時）: 児童チャネル購読
  after_create do
    user.subscriptions.create!(channel_id: Channel::JUVENILE_CHANNEL_ID)
  end

  # trial開始: 公式チャネル購読
  after_update if: :trialing_started? do
    user.email_digest.update!(trial_ended_at: trial_end_at)
    user.subscriptions.create!(channel_id: Channel::OFFICIAL_CHANNEL_ID)
  end

  # basicプラン解約: 無料チャネル以外解約・自作チャネルの削除・配信停止
  after_update if: :basic_plan_canceled? do
    user.channels.destroy_all  # 自作チャネルと配信予約を削除
    user.subscriptions.where.not(channel_id: Channel::JUVENILE_CHANNEL_ID).destroy_all # 児童チャネル以外配信停止
  end

  # 退会: すべてのチャネル解約・自作チャネルの削除・配信停止
  after_update if: :free_plan_canceled? do
    user.destroy!
  end


  def schedule_trial(apply_at)
    raise 'trial ended' if plan == 'basic' || trial_end_at.present?
    self.membership_logs.create!(plan: 'basic', trialing: true, apply_at: apply_at)
    self.membership_logs.create!(plan: 'free', apply_at: apply_at.since(1.month)) # 変更がなければ1ヶ月後にfreeプランに戻る
    self.update!(trial_end_at: apply_at.end_of_month)
  end

  # 決済情報登録して、翌月末かトライアル終了後から課金開始
  def schedule_billing(apply_at)
    raise 'already billing' if plan == 'basic' && !trialing?   # ありえるのは free-active OR basic-trialingからの登録
    self.membership_logs.scheduled.update_all(canceled: true)
    self.membership_logs.create!(plan: 'basic', apply_at: apply_at)
  end

  # 月末で解約してfreeプランに戻る
  def schedule_cancel(apply_at)
    raise 'not billing' if plan == 'free' || trialing?
    self.membership_logs.create!(plan: 'free', apply_at: apply_at)
  end


  private

  # 課金開始時期
  ## トライアル開始前 -> 翌々月初、 トライアル中 -> 翌月初、 トライアル終了後 -> 翌月初
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
    saved_change_to_plan == ['basic', 'free']
  end

  def free_plan_canceled?
    plan_or_trialing_changed? && plan == nil
  end
end
