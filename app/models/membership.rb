class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  enum status: { active: 1, trialing: 2, canceled: 3 }

  after_update :start_trialing, if: :trialing_started?
  after_update :cancel_basic_plan, if: :basic_plan_canceled?
  after_update :cancel_free_plan, if: :free_plan_canceled?

  def schedule_trial
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.create!(plan: 'basic', status: :trialing, apply_at: Time.current.next_month.beginning_of_month)
      self.membership_logs.create!(plan: 'free', status: :active, apply_at: Time.current.next_month.end_of_month)
    end
  end

  # 決済情報登録して、翌月から課金開始
  def schedule_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.scheduled.update_all(canceled: true)
      self.membership_logs.create!(plan: 'basic', status: :active, apply_at: Time.current.next_month.beginning_of_month)
    end
  end

  # 月末で解約してfreeプランに戻る
  def cancel_billing
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      self.membership_logs.scheduled.update_all(canceled: true)
      self.membership_logs.create!(plan: 'free', status: :active, apply_at: Time.current.next_month.beginning_of_month)
    end
  end

  private

  ###########################################################
  # callbackの条件判定メソッド
  ###########################################################
  def plan_or_status_changed?
    (saved_changes.keys & ['plan', 'status']).present?
  end

  def trialing_started?
    plan_or_status_changed? && plan == 'basic' && trialing?
  end

  def basic_plan_canceled?
    saved_change_to_plan == ['basic', 'free'] && active?
  end

  def free_plan_canceled?
    plan_or_status_changed? && plan == 'free' && canceled?
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
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      user.channels.destroy_all  # 自作チャネルと配信予約を削除
      user.subscriptions.where.not(channel_id: Channel::JUVENILE_CHANNEL_ID).destroy_all # 児童チャネル以外配信停止
    end
  end

  # 退会: すべてのチャネル解約・自作チャネルの削除・配信停止
  def cancel_free_plan
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      user.channels.destroy_all  # 自作チャネルと配信予約を削除
      user.subscriptions.destroy_all # すべてのsubscriptionを解約
      user.update!(activation_state: nil) # ログインできなくする
    end
  end
end
