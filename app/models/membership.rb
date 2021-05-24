class Membership < ApplicationRecord
  belongs_to :user, foreign_key: :id
  has_many :membership_logs, foreign_key: :user_id

  MAXIMUM_SUBSCRIPTIONS_COUNT = { free: 1, basic: 3 }.freeze

  # 翌月初からトライアル開始
  ## TODO: 過去にトライアル済みのケースの対応
  def schedule_billing
    raise 'already billing' if plan != 'free'
    beginning_of_next_month = Time.current.next_month.beginning_of_month
    self.membership_logs.create!(plan: 'basic', trialing: true,  apply_at: beginning_of_next_month) # 翌月初からトライアル開始
    self.membership_logs.create!(plan: 'basic', trialing: false, apply_at: beginning_of_next_month.next_month) # 翌々月初から課金開始
  end

  # 月末で解約してfreeプランに戻る
  def schedule_cancel(apply_at)
    raise 'not billing' if plan == 'free'
    beginning_of_next_month = Time.current.next_month.beginning_of_month

    # TODO: Stripeの解約処理

    self.membership_logs.create!(plan: 'free', apply_at: apply_at || beginning_of_next_month)
  end
end
