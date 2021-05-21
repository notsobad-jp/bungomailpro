class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  MAXIMUM_SUBSCRIPTIONS_COUNT = { free: 1, basic: 3 }.freeze

  # basicプラン開始: 公式チャネル購読
  ## 基本はbasicプランのトライアル開始時。再課金のケースではトライアルなしでいきなり開始パターンもありえる
  after_update if: :basic_plan_started? do
    user.email_digest.update!(trial_ended_at: self.trial_end_at)
    user.subscriptions.new(channel_id: Channel::OFFICIAL_CHANNEL_ID).save!(validate: false) # FIXME: subscriptionsのvalidationが先に来てしまうので一旦スキップ
  end

  # basicプラン解約: 無料チャネル以外解約・自作チャネルの削除・配信停止
  after_update if: :basic_plan_canceled? do
    user.channels.destroy_all  # 自作チャネルと配信予約を削除
    user.subscriptions.where.not(channel_id: Channel::JUVENILE_CHANNEL_ID).destroy_all # 児童チャネル以外配信停止
  end


  # 翌月初からトライアル開始
  def schedule_billing(apply_at)
    raise 'already billing' if plan != 'free'
    self.membership_logs.create!(plan: 'basic', apply_at: apply_at)
  end

  # 月末で解約してfreeプランに戻る
  def schedule_cancel(apply_at)
    raise 'not billing' if plan == 'free'
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
  def basic_plan_started?
    saved_change_to_plan == ['free', 'basic']
  end

  def basic_plan_canceled?
    saved_change_to_plan == ['basic', 'free']
  end
end
